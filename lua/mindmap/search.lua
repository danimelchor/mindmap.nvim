local M = {}
M.handle = nil

function M.start_server()
    if M.handle ~= nil then
        return
    end

    local uv = vim.loop
    local stderr = uv.new_pipe(false)

    M.handle = uv.spawn("mindmap", {
        args = { "server" },
        stdio = { nil, nil, stderr },
    }, function(code, signal)
        if code ~= 0 then
            print("Mindmap server exited with code " .. code .. " and signal " .. signal)
        else
            print("Mindmap server exited")
        end
    end)
    vim.notify("Started mindmap server", vim.log.levels.INFO)

    stderr:read_start(function(err, data)
        M.stop_server()
        error("[Mindmap server] " .. data .. " (" .. vim.inspect(err) .. ")")
    end)
end

function M.stop_server()
    if M.handle == nil then
        return
    end

    local uv = vim.loop
    uv.process_kill(M.handle, "sigterm")
    M.watcher_handle = nil
    vim.schedule(function()
        vim.notify("Stopped mindmap server", vim.log.levels.INFO)
    end)
end

function M.fzf_lua(host)
    M.start_server()

    local cmd = "curl -G -s --data-urlencode 'q=<query>' " .. host
    require('fzf-lua').fzf_live(cmd, {
        fn_transform = function(x)
            return require('fzf-lua').make_entry.file(x, {
                file_icons = true,
                color_icons = true
            })
        end,
        previewer = "builtin",
        prompt = "Mindmap> ",
        actions = {
            ["default"] = require('fzf-lua').actions.file_edit,
            ["ctrl-s"] = require('fzf-lua').actions.file_vsplit,
            ["ctrl-o"] = M.new_note,
        },
    })
end

return M
