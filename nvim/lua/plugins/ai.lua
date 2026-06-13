-- ai.lua  --  seamless Claude Code integration inside Neovim
--
-- claudecode.nvim speaks Claude Code's WebSocket/MCP protocol, so the editor
-- and the `claude` CLI share selection, diagnostics and at-mentions — letting
-- you drive an AI pair-programming session without leaving Neovim.
--
-- Requires the `claude` CLI on PATH (Claude Code). Harmless if it's absent:
-- the commands simply do nothing until it's installed.

return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" }, -- terminal UI provider
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend",
      "ClaudeCodeAdd", "ClaudeCodeDiffAccept", "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      -- Send the current selection / buffer as context.
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>ab",
        "<cmd>ClaudeCodeAdd %<cr>",
        desc = "Add current buffer to Claude context",
      },
      -- Accept / reject Claude's proposed diffs.
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Claude diff" },
    },
    opts = {
      -- Open the Claude terminal in a right-hand vertical split.
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
        provider = "snacks",
      },
      diff_opts = {
        auto_close_on_accept = true,
        vertical_split = true,
      },
    },
  },

  -- snacks.nvim provides the terminal window used above (loaded on demand).
  { "folke/snacks.nvim", lazy = true, opts = {} },
}
