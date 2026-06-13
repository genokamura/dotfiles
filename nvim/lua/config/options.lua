-- options.lua  --  core editor settings (no plugins)

local opt = vim.opt

-- UI / appearance
opt.number = true
opt.relativenumber = true       -- relative lines for fast j/k motions
opt.cursorline = true
opt.signcolumn = "yes"          -- avoid layout shift when signs appear
opt.termguicolors = true
opt.showmode = false            -- mode shown in the statusline instead
opt.scrolloff = 8               -- keep context around the cursor
opt.sidescrolloff = 8
opt.wrap = false
opt.colorcolumn = "100"
opt.pumheight = 12              -- cap completion menu height
opt.cmdheight = 1
opt.laststatus = 3              -- global statusline
opt.splitright = true
opt.splitbelow = true
opt.fillchars = { eob = " " }   -- hide ~ on empty lines

-- Editing / indentation
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.virtualedit = "block"       -- visual-block past EOL

-- Search
opt.ignorecase = true
opt.smartcase = true            -- case-sensitive when query has uppercase
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = "split"        -- live preview of :substitute

-- Behaviour
opt.mouse = "a"
opt.undofile = true             -- persistent undo
opt.swapfile = false
opt.updatetime = 250            -- snappier CursorHold / diagnostics
opt.timeoutlen = 400            -- which-key responsiveness
opt.confirm = true              -- prompt instead of failing on unsaved changes
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 0

-- Splitting long-running things across the gutter cleanly
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Files
opt.fileencoding = "utf-8"
opt.autoread = true

-- Diagnostics presentation
vim.diagnostic.config({
  virtual_text = { spacing = 2, prefix = "●" },
  severity_sort = true,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
})

-- Rounded borders for hover / signature help
vim.o.winborder = "rounded"
