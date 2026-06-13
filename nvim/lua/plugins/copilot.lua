-- copilot.lua  --  GitHub Copilot inline (ghost-text) code completion
--
-- Coexists with blink.cmp: blink provides the popup menu (LSP/path/snippets),
-- Copilot provides inline multi-line suggestions. `hide_during_completion`
-- suppresses the ghost text while the blink menu is open so they don't clash.
--
-- First-time setup: run `:Copilot auth` (requires a GitHub Copilot subscription)
-- and `:Copilot status` to verify. Needs Node.js >= 18 on PATH.

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,          -- show suggestions as you type
        hide_during_completion = true, -- yield to the blink.cmp menu
        keymap = {
          accept = "<C-l>",   -- accept the whole suggestion
          next = "<M-]>",     -- cycle to next suggestion
          prev = "<M-[>",     -- cycle to previous
          dismiss = "<C-]>",  -- dismiss current suggestion
        },
      },
      panel = { enabled = false },    -- inline-only; no separate panel UI
      -- Enable in a few prose filetypes too; "." disables for unknown ft.
      filetypes = {
        markdown = true,
        gitcommit = true,
        yaml = true,
        help = false,
        ["."] = false,
      },
    },
    keys = {
      {
        "<leader>ap",
        function()
          require("copilot.suggestion") -- ensure loaded
          vim.cmd("Copilot toggle")
        end,
        desc = "Toggle Copilot",
      },
      { "<leader>aP", "<cmd>Copilot status<cr>", desc = "Copilot status" },
    },
  },
}
