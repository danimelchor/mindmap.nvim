# mindmap.nvim

`mindmap.nvim` is a wrapper for [MindMap](https://github.com/danimelchor/mindmap) that allows you to search your notes using semantic search
directly in neovim using your favorite fuzzy finder like `fzf`, `fzf-lua` or `telescope`.

## Installation

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
| `:MindMap fzf` | Search using fzf |
| `:MindMap telescope` | Search using telescope |
