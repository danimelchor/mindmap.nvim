local M = {}
M.watcher_handle = nil

function M.start_watcher()
    if M.watcher_handle ~= nil then
        return
    end

    vim.notify("Starting mindmap watcher", vim.log.levels.INFO)
    local uv = vim.loop

    local home = vim.fn.expand("~")
    local cwd = home .. "/projects/mindmap/mindmap"

    local stderr = uv.new_pipe(false)
    local stdout = uv.new_pipe(false)

    M.watcher_handle = uv.spawn("mindmap", {
        args = { "watch" },
        stdio = { nil, stdout, stderr },
        cwd = cwd,
    }, function(code, signal)
        if code ~= 0 then
            print("Mindmap watcher exited with code " .. code .. " and signal " .. signal)
        else
            print("Mindmap watcher exited")
        end
    end)

    stdout:read_start(function(err, data)
        assert(not err, err)
        if data then
            print("Mindmap watcher out: " .. data)
        end
    end)

    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            vim.notify("[Mindmap watcher] " .. data, vim.log.levels.ERROR)
        end
    end)
end

function M.stop_watcher()
    local uv = vim.loop
    uv.process_kill(M.watcher_handle, "sigterm")
    M.watcher_handle = nil
    vim.notify("Stopped mindmap watcher", vim.log.levels.INFO)
end

return M