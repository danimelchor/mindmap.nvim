# mindmap.nvim

`mindmap.nvim` is a wrapper for [MindMap](https://github.com/danimelchor/mindmap) that allows you to search your notes using semantic search
directly in neovim using `fzf-lua`.


https://github.com/danimelchor/mindmap.nvim/assets/24496843/0f72f0b3-af8d-4419-b77d-29cd999661d9


## Installation

> [!IMPORTANT]
> You need to call `setup` to initialize the plugin.

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'dmelchor/mindmap.nvim', {'branch': 'main'}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use { "dmelchor/mindmap.nvim" }
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "dmelchor/mindmap.nvim",
  config = function()
    require("mindmap").setup()
  end
}
```

## Usage

`mindmap.nvim` will automatically start up the watcher when you open a file in your configured
directory. It will also automatically start the server the first time you run a search.

| Command | Description |
| --- | --- |
| `:MindMap start` | Start the server and watcher |
| `:MindMap disable` | Stop the server and watcher |
| `:MindMap enable_watcher` | Enable the watcher |
| `:MindMap disable_watcher` | Disable the watcher |
| `:MindMap enable_server` | Enable the server |
| `:MindMap disable_server` | Disable the server |
| `:MindMap fzf_lua` | Search using fzf-lua |


## Configuration

You can configure `mindmap.nvim` by calling `setup` with a table of options. The following are the default options.

```lua
require("mindmap").setup({
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
})
```
