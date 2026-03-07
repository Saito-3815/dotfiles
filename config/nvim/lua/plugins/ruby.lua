return {
  -- ruby-lspをbundle exec経由で起動 (Mason不使用)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruby_lsp = {
          mason = false,
          init_options = {
            formatter = "rubocop",
          },
        },
      },
    },
  },

  -- Treesitter: endwise + Ruby/ERBパーサー
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "RRethy/nvim-treesitter-endwise" },
    opts = function(_, opts)
      opts.endwise = { enable = true }
      opts.indent = { enable = true, disable = { "ruby" } }
      vim.list_extend(opts.ensure_installed or {}, {
        "ruby",
        "embedded_template",
      })
    end,
  },

  -- vim-rails: Railsナビゲーション (:Emodel, :Econtroller等)
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby" },
  },
}
