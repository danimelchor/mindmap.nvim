local Mindmap = {}

local defaultOpts = {
    log_file = vim.fn.expand("~") .. "/.config/mindmap/mindmap.log",
    data_path = vim.fn.expand("~") .. "/mindmap/*.md",
}

local function setup_autocmds()
    Mindmap.augroup = vim.api.nvim_create_augroup("MindmapGroup", {
        clear = true,
    })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = Mindmap.augroup,
        pattern = Mindmap.opts.data_path,
        callback = Mindmap.start_watcher,
    })

    vim.api.nvim_create_autocmd("VimLeave", {
        group = Mindmap.augroup,
        pattern = Mindmap.opts.data_path,
        callback = Mindmap.stop_watcher,
    })
end

local function clear_autocmds()
    vim.api.nvim_del_augroup_by_id(Mindmap.augroup)
end

local function setup_cmds()
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
    if Mindmap.watcher_handle == nil then
        vim.notify("Mindmap watcher is not running", vim.log.levels.WARN)
        return
    end
    clear_autocmds()
    Mindmap.stop_watcher()
end

function Mindmap.enable()
    if Mindmap.watcher_handle ~= nil then
        vim.notify("Mindmap watcher is already running", vim.log.levels.WARN)
        return
    end
    setup_autocmds()
    Mindmap.start_watcher()
end

function Mindmap.setup(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", defaultOpts, opts)
    Mindmap.opts = opts
    Mindmap.watcher_handle = nil
    setup_cmds()
    setup_autocmds()
end

function Mindmap.logs()
    -- Open the log file
    local path = Mindmap.opts.log_file
    vim.cmd("edit " .. path)
end

Mindmap.fzf_lua = require("mindmap.search").fzf_lua
Mindmap.start_watcher = require("mindmap.watcher").start_watcher
Mindmap.stop_watcher = require("mindmap.watcher").stop_watcher

return Mindmap
