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
        callback = function()
            Mindmap.stop_watcher()
            Mindmap.stop_server()
        end,
    })
end

local function clear_autocmds()
    vim.api.nvim_del_augroup_by_id(Mindmap.augroup)
end

local function setup_cmds()
    local commands = {
        "logs",
        "start",
        "stop",
        "fzf",
        "start_server",
        "stop_server",
        "start_watcher",
        "stop_watcher",
    }

    vim.api.nvim_create_user_command("Mindmap", function(command)
            local args = vim.split(command.args, " ")
            local cmd = table.remove(args, 1)
            if not cmd then
                print("No command given")
                return
            end

            if not vim.tbl_contains(commands, cmd) then
                print("Unknown command: " .. cmd)
                return
            end

            local fn = Mindmap[cmd]
            if not fn then
                print("No function for command: " .. cmd)
                return
            end

            fn(unpack(args))
        end,
        {
            nargs = "?",
        })
end

function Mindmap.stop()
    clear_autocmds()
    Mindmap.stop_watcher()
    Mindmap.stop_server()
end

function Mindmap.start()
    setup_autocmds()
    Mindmap.start_watcher()
    Mindmap.start_server()
end

function Mindmap.setup(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", defaultOpts, opts)
    Mindmap.opts = opts

    setup_cmds()
    setup_autocmds()
end

function Mindmap.logs()
    -- Open the log file
    local path = Mindmap.opts.log_file
    vim.cmd("edit " .. path)
end

Mindmap.fzf_lua = require("mindmap.search").fzf_lua
Mindmap.start_server = require("mindmap.search").start_server
Mindmap.stop_server = require("mindmap.search").stop_server
Mindmap.start_watcher = require("mindmap.watcher").start_watcher
Mindmap.stop_watcher = require("mindmap.watcher").stop_watcher

return Mindmap
