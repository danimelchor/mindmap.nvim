local MindMap = {}

local defaultOpts = {
    data_path = vim.fn.expand("~") .. "/notes/*.md",
    keybinds = {
        todays_note = "<LEADER>m",
        new_note = "<LEADER>M",
    },
    watcher = {
        auto_start = true,
        auto_stop = true,
    },
    server = {
        host = "127.0.0.1:5001",
    },
}

local function setup_autocmds()
    MindMap.augroup = vim.api.nvim_create_augroup("MindMapGroup", {
        clear = true,
    })

    if MindMap.opts.keybinds then
        vim.keymap.set(
            "n",
            MindMap.opts.keybinds.todays_note,
            MindMap.todays_note,
            { noremap = true, silent = true }
        )
        vim.keymap.set(
            "n",
            MindMap.opts.keybinds.new_note,
            MindMap.new_note,
            { noremap = true, silent = true }
        )
    end

    if MindMap.opts.watcher.auto_start then
        vim.api.nvim_create_autocmd("BufEnter", {
            group = MindMap.augroup,
            pattern = MindMap.MindMap.opts.data_path,
            callback = MindMap.start_watcher,
        })
    end

    if MindMap.opts.watcher.auto_stop then
        vim.api.nvim_create_autocmd("VimLeave", {
            group = MindMap.augroup,
            pattern = MindMap.opts.data_path,
            callback = function()
                MindMap.stop_watcher()
                MindMap.stop_server()
            end,
        })
    end
end

local function clear_autocmds()
    vim.api.nvim_del_augroup_by_id(MindMap.augroup)
end

local function setup_cmds()
    vim.api.nvim_create_user_command("MindMap", function(command)
            local args = vim.split(command.args, " ")
            local cmd = table.remove(args, 1)
            if cmd == nil or cmd == "" then
                print("No command given. Available commands:")
                for c, _ in pairs(MindMap) do
                    if c ~= "setup" then
                        print(" - " .. c)
                    end
                end
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

function MindMap.todays_note()
    local notes_dir = vim.fn.expand("~") .. "/notes"
    local today = os.date("%Y%m%d")
    local today_nice = os.date("%Y-%m-%d")
    local note_path = notes_dir .. "/" .. today .. ".md"
    local header = { "<--- " .. today_nice .. " --->", "", "# Notes for " .. today_nice, "" }

    vim.cmd("cd " .. notes_dir)
    local exists = vim.fn.filereadable(note_path) == 1
    if not exists then
        vim.fn.writefile(header, note_path)
    end
    vim.cmd("edit " .. note_path)
end

function MindMap.new_note()
    local notes_dir = vim.fn.expand("~") .. "/notes"
    local today_nice = os.date("%Y-%m-%d")
    local header = { "<--- " .. today_nice .. " --->", "" }
    vim.cmd("cd " .. notes_dir)
    vim.cmd("enew")
    vim.fn.append(0, header)
    vim.bo.filetype = "markdown"
end

MindMap.fzf_lua = function()
    require("mindmap.search").fzf_lua(MindMap.server.host)
end
MindMap.start_server = require("mindmap.search").start_server
MindMap.stop_server = require("mindmap.search").stop_server
MindMap.start_watcher = require("mindmap.watcher").start_watcher
MindMap.stop_watcher = require("mindmap.watcher").stop_watcher

return MindMap
