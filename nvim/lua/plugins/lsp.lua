-- lsp.lua  --  language servers (mason) + formatting (conform)
-- Uses the Neovim 0.11 native vim.lsp.config / vim.lsp.enable API
-- (no deprecated require("lspconfig") framework).

return {
  -- Mason: manage LSP servers / formatters / linters.
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    opts = { ui = { border = "rounded" } },
  },

  -- LSP configuration. nvim-lspconfig now just ships the default per-server
  -- configs under its `lsp/` runtime dir; we layer overrides via vim.lsp.config.
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Servers to manage. Empty table == defaults from nvim-lspconfig.
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              telemetry = { enable = false },
            },
          },
        },
        bashls = {},
        pyright = {},
        ts_ls = {},
        gopls = {},
        rust_analyzer = {},
        jsonls = {},
        yamlls = {},
      }

      -- Advertise completion capabilities (blink.cmp) to every server.
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- Apply per-server overrides (merged on top of nvim-lspconfig defaults).
      for name, cfg in pairs(servers) do
        if next(cfg) ~= nil then
          vim.lsp.config(name, cfg)
        end
      end

      -- mason-lspconfig installs the servers and (automatic_enable) calls
      -- vim.lsp.enable() for each once available.
      --
      -- Only auto-install servers whose toolchain is present. gopls needs the
      -- Go toolchain (`go install`), so skip it unless `go` is on PATH —
      -- otherwise mason reports a failed install on every startup. The config
      -- still applies, so `:MasonInstall gopls` works once Go is installed.
      local needs_toolchain = { gopls = "go" }
      local ensure = {}
      for name in pairs(servers) do
        local tool = needs_toolchain[name]
        if not tool or vim.fn.executable(tool) == 1 then
          ensure[#ensure + 1] = name
        end
      end
      require("mason-lspconfig").setup({
        ensure_installed = ensure,
        automatic_enable = true,
      })

      -- Buffer-local keymaps once a server attaches.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("dotfiles_lsp_attach", { clear = true }),
        callback = function(event)
          local map = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = event.buf, desc = "LSP: " .. desc })
          end
          map("gd", "<cmd>Telescope lsp_definitions<cr>", "Goto definition")
          map("gr", "<cmd>Telescope lsp_references<cr>", "References")
          map("gI", "<cmd>Telescope lsp_implementations<cr>", "Goto implementation")
          map("gy", "<cmd>Telescope lsp_type_definitions<cr>", "Type definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("K", vim.lsp.buf.hover, "Hover docs")
          map("<leader>cr", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>cs", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")

          -- Inlay hints toggle (if the server supports it).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "Toggle inlay hints")
          end
        end,
      })
    end,
  },

  -- Formatting on save with conform.nvim
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        sh = { "shfmt" },
        go = { "gofmt" },
        rust = { "rustfmt" },
      },
      format_on_save = function(bufnr)
        -- Allow disabling per-buffer/global via a variable.
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_fallback = true }
      end,
    },
    init = function()
      -- :FormatToggle command for autoformat-on-save (! = buffer-local).
      vim.api.nvim_create_user_command("FormatToggle", function(args)
        if args.bang then
          vim.b.disable_autoformat = not vim.b.disable_autoformat
        else
          vim.g.disable_autoformat = not vim.g.disable_autoformat
        end
      end, { bang = true, desc = "Toggle format-on-save (! = buffer-local)" })
    end,
  },
}
