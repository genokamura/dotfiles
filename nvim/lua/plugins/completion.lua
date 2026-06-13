-- completion.lua  --  blink.cmp: fast, low-config completion (Rust fuzzy matcher)
return {
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "*", -- use a released tag (ships prebuilt fuzzy binary)
    dependencies = {
      "rafamadriz/friendly-snippets", -- community snippet collection
    },
    opts = {
      keymap = {
        preset = "default", -- C-y accept, C-n/C-p navigate, C-space toggle
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = { border = "rounded" },
        -- Inline ghost text is handled by Copilot (see plugins/copilot.lua).
        ghost_text = { enabled = false },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
