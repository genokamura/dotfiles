-- autocmds.lua  --  autocommands and WSL2 clipboard provider

local augroup = function(name)
  return vim.api.nvim_create_augroup("dotfiles_" .. name, { clear = true })
end

-- Highlight text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function() (vim.hl or vim.highlight).on_yank({ timeout = 150 }) end,
})

-- Return to last edit position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Trim trailing whitespace on save (skip filetypes where it matters)
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("trim_whitespace"),
  callback = function()
    local skip = { markdown = true, diff = true, gitcommit = true }
    if skip[vim.bo.filetype] then return end
    local save = vim.fn.winsaveview()
    vim.cmd([[silent! keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- Close throwaway buffers with q
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "qf", "man", "lspinfo", "checkhealth", "startuptime" },
  callback = function(args)
    vim.bo[args.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true })
  end,
})

-- Auto-create missing parent directories on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_mkdir"),
  callback = function(args)
    if args.match:match("^%w%w+://") then return end -- skip remote/special buffers
    local dir = vim.fn.fnamemodify(vim.uv.fs_realpath(args.match) or args.match, ":p:h")
    vim.fn.mkdir(dir, "p")
  end,
})

-- ---------------------------------------------------------------------------
-- WSL2 clipboard: route +/* registers through win32yank (or clip.exe).
-- This makes y/p sync with the Windows clipboard transparently.
-- ---------------------------------------------------------------------------
local function in_wsl()
  if vim.fn.has("wsl") == 1 then return true end
  local ok, v = pcall(vim.fn.readfile, "/proc/version")
  return ok and (table.concat(v):lower():match("microsoft") ~= nil)
end

if in_wsl() then
  if vim.fn.executable("win32yank.exe") == 1 then
    vim.g.clipboard = {
      name = "win32yank-wsl",
      copy = {
        ["+"] = "win32yank.exe -i --crlf",
        ["*"] = "win32yank.exe -i --crlf",
      },
      paste = {
        ["+"] = "win32yank.exe -o --lf",
        ["*"] = "win32yank.exe -o --lf",
      },
      cache_enabled = 0,
    }
  elseif vim.fn.executable("clip.exe") == 1 then
    vim.g.clipboard = {
      name = "wsl-clip",
      copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
      paste = {
        ["+"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
        ["*"] = 'powershell.exe -NoProfile -Command Get-Clipboard',
      },
      cache_enabled = 0,
    }
  end
end

-- Sync the unnamed register with the system clipboard.
vim.opt.clipboard = "unnamedplus"
