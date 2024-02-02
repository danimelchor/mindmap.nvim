local MindMap = {}

local defaultOpts = {
    log_file = vim.fn.expand("~") .. "/.config/mindmap/mindmap.log",
    data_path = vim.fn.expand("~") .. "/mindmap/*.md",
}

local function setup_autocmds()
    MindMap.augroup = vim.api.nvim_create_augroup("MindMapGroup", {
        clear = true,
    })

    vim.keymap.set(
        "n",
        "<LEADER>z",
        MindMap.todays_note,
        { noremap = true, silent = true }
    )

    vim.api.nvim_create_autocmd("BufEnter", {
        group = MindMap.augroup,
        pattern = MindMap.opts.data_path,
        callback = MindMap.start_watcher,
    })

    vim.api.nvim_create_autocmd("VimLeave", {
        group = MindMap.augroup,
        pattern = MindMap.opts.data_path,
        callback = function()
            MindMap.stop_watcher()
            MindMap.stop_server()
        end,
    })
end

local function clear_autocmds()
    vim.api.nvim_del_augroup_by_id(MindMap.augroup)
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
        "todays_note",
    }

    vim.api.nvim_create_user_command("MindMap", function(command)
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

            local fn = MindMap[cmd]
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

function MindMap.stop()
    clear_autocmds()
    MindMap.stop_watcher()
    MindMap.stop_server()
end

function MindMap.start()
    setup_autocmds()
    MindMap.start_watcher()
    MindMap.start_server()
end

function MindMap.setup(opts)
    opts = opts or {}
    opts = vim.tbl_extend("force", defaultOpts, opts)
    MindMap.opts = opts

    setup_cmds()
    setup_autocmds()
end

function MindMap.logs()
    -- Open the log file
    local path = MindMap.opts.log_file
    vim.cmd("edit " .. path)
end

function MindMap.todays_note()
    local notes_dir = vim.fn.expand("~") .. "/mindmap"
    local today = os.date("%Y%m%d")
    local today_nice = os.date("%Y-%m-%d")
    local note_path = notes_dir .. "/" .. today .. ".md"
    local header = { "<--- " .. today_nice .. " --->", "", "" }

    if vim.fn.filereadable(note_path) == 0 then
        vim.fn.writefile(header, note_path)
    end

    -- Edit line 3
    vim.cmd("edit +3 " .. note_path)
end

MindMap.fzf_lua = require("mindmap.search").fzf_lua
MindMap.start_server = require("mindmap.search").start_server
MindMap.stop_server = require("mindmap.search").stop_server
MindMap.start_watcher = require("mindmap.watcher").start_watcher
MindMap.stop_watcher = require("mindmap.watcher").stop_watcher

return MindMap
