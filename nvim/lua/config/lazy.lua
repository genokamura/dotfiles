-- lazy.lua  --  bootstrap the lazy.nvim plugin manager and import specs

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- Every file under lua/plugins/ returns a plugin spec.
    { import = "plugins" },
  },
  defaults = { lazy = true },         -- lazy-load by default; specs opt in to eager
  install = { colorscheme = { "tokyonight", "habamax" } },
  rocks = { enabled = false },        -- no plugin needs luarocks; skip hererocks
  checker = { enabled = true, notify = false },  -- background update checks
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- Trim built-in plugins we don't use for a faster startup.
      disabled_plugins = {
        "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
        "netrwPlugin", "matchit", "matchparen",
      },
    },
  },
})

-- Quick access to the plugin manager UI.
vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy (plugins)" })
