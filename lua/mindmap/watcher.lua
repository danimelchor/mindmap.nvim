local M = {}
M.watcher_handle = nil

function M.start_watcher()
    if M.watcher_handle ~= nil then
        return
    end

    vim.notify("Starting mindmap watcher", vim.log.levels.INFO)
    local uv = vim.loop
    local stderr = uv.new_pipe(false)

    M.watcher_handle = uv.spawn("mindmap", {
        args = { "watch" },
        stdio = { nil, stderr },
    }, function(code, signal)
        if code ~= 0 then
            print("Mindmap watcher exited with code " .. code .. " and signal " .. signal)
        else
            print("Mindmap watcher exited")
        end
    end)

    stderr:read_start(function(err, data)
        assert(not err, err)
        if data then
            print("[Mindmap watcher] " .. data)
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
