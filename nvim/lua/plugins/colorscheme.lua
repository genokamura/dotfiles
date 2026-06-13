-- colorscheme.lua  --  Tokyonight: clean, true-color, good terminal contrast
return {
  {
    "folke/tokyonight.nvim",
    lazy = false,    -- load during startup; it's the active theme
    priority = 1000, -- ...before any other plugin
    opts = {
      style = "night",
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
      },
      on_highlights = function(hl, c)
        -- Slightly brighter inactive borders for keyboard-driven split work.
        hl.WinSeparator = { fg = c.blue0 }
      end,
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
