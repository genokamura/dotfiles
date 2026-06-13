-- init.lua  --  Neovim entrypoint
-- Lightweight, keyboard-driven, WSL2-aware. Plugins managed by lazy.nvim.
--
-- Load order matters: leader keys must be set before lazy.nvim loads plugins
-- so that plugin-defined mappings pick up the right leader.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
