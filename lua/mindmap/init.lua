local Mindmap = {}

local defaultOpts = {
    log_file = vim.fn.expand("~") .. "/.config/mindmap/mindmap.log",
    data_path = vim.fn.expand("~") .. "/mindmap/*.md",
}

local function start_process()
    if Mindmap.handle ~= nil then
        return
    end

    vim.notify("Starting mindmap watcher", vim.log.levels.INFO)
    local uv = vim.loop
    Mindmap.handle = uv.spawn("mindmap", {
        args = { "watch" },
        stdio = { nil, nil, nil },
    }, function(code, signal)
        if code ~= 0 then
            vim.notify("Mindmap watcher exited with code " .. code .. " and signal " .. signal, vim.log.levels.ERROR)
        else
            vim.notify("Mindmap watcher exited", vim.log.levels.INFO)
        end
    end)
end

local function kill_process()
    local uv = vim.loop
    uv.process_kill(Mindmap.handle, "sigterm")
    Mindmap.handle = nil
    vim.notify("Stopped mindmap watcher", vim.log.levels.INFO)
end

function Mindmap._setup_autocmds()
    Mindmap.augroup = vim.api.nvim_create_augroup("MindmapGroup", {
        clear = true,
    })

    Mindmap.aucmd = vim.api.nvim_create_autocmd("BufEnter", {
        group = Mindmap.augroup,
        pattern = Mindmap.opts.data_path,
        callback = start_process,
    })
end

function Mindmap._clear_autocmds()
    vim.api.nvim_del_augroup_by_id(Mindmap.augroup)
end

function Mindmap._setup_cmds()
    vim.api.nvim_create_user_command("Mindmap", function(command)
            local args = command.args
            if args == "logs" then
                Mindmap.logs()
            elseif args == "enable" then
                Mindmap.enable()
            elseif args == "disable" then
                Mindmap.disable()
            elseif args == "fzf" then
                Mindmap.fzf_lua()
            else
                print("Invalid argument: " .. args)
            end
        end,
        {
            nargs = "?",
        })
end

function Mindmap.disable()
    if Mindmap.handle == nil then
        vim.notify("Mindmap watcher is not running", vim.log.levels.WARN)
        return
    end
    Mindmap._clear_autocmds()
    kill_process()
end

function Mindmap.enable()
    if Mindmap.handle ~= nil then
        vim.notify("Mindmap watcher is already running", vim.log.levels.WARN)
        return
    end
    Mindmap._setup_autocmds()
    start_process()
end

function Mindmap.setup(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", defaultOpts, opts)
    Mindmap.opts = opts
    Mindmap.handle = nil
    Mindmap._setup_cmds()
    Mindmap._setup_autocmds()
end

function Mindmap.fzf_lua()
    require('fzf-lua').fzf_live("mindmap query '<query>' --format raw", {
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
        }
    })
end

function Mindmap.logs()
    -- Open the log file
    local path = Mindmap.opts.log_file
    vim.cmd("edit " .. path)
end

return Mindmap
