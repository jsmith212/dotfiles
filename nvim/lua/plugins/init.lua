return {
  -- Packages
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim", -- Mason must be loaded first
    },
    cmd = {
      "MasonToolsInstall",
      "MasonToolsInstallSync",
      "MasonToolsUpdate",
      "MasonToolsUpdateSync",
      "MasonToolsClean",
    },
    opts = function()
      return require("configs.mason").opts
    end,
  },

  -- Formatting and highlighting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "css",
        "cue",
        "dockerfile",
        "go",
        "hcl",
        "helm",
        "html",
        "javascript",
        "jinja",
        "json",
        "just",
        "lua",
        "make",
        "markdown",
        "markdown_inline",
        "mermaid",
        "meson",
        "ninja",
        "proto",
        "python",
        "rust",
        "scss",
        "sql",
        "svelte",
        "templ",
        "toml",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
    },
  },
  {
    "MunifTanjim/prettier.nvim",
    lazy = false,
    config = function()
      require("prettier").setup {
        bin = "prettierd",
        cli_options = {
          html_whitespace_sensitivity = "css",
        },
      }
    end,
  },
  {
    "malbertzard/inline-fold.nvim",
    opts = {
      defaultPlaceholder = "…",
      queries = {
        html = {
          { pattern = 'class="([^"]*)"', placeholder = "@" }, -- classes in html
          { pattern = 'href="(.-)"' },                        -- hrefs in html
          { pattern = 'src="(.-)"' },                         -- HTML img src attribute
        },
      },
    },
    config = function(_, _)
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.html", "*.js", "*.ts", "*.jsx", "*.tsx", "*.vue", "*.svelte", "*.templ" },
        callback = function(_)
          if not require("inline-fold.module").isHidden then
            vim.cmd "InlineFoldToggle"
          end
        end,
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    lazy = false,
    opts = {
      prompt_func_return_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      prompt_func_param_type = {
        go = false,
        java = false,
        cpp = false,
        c = false,
        h = false,
        hpp = false,
        cxx = false,
      },
      printf_statements = {},
      print_var_statements = {},
      show_success_message = false,
    },
  },

  -- Dad Bod
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod",                     lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },

  -- Completions
  {
    -- NVChad includes this by default, need to disable it
    "hrsh7th/nvim-cmp",
    enabled = false,
  },
  {
    "saghen/blink.cmp",
    lazy = false,
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*", -- Main is apparently broken
        dependencies = { "rafamadriz/friendly-snippets" },
        build = "make install_jsregexp",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          require "configs.luasnip"
        end,
      },
      "moyiz/blink-emoji.nvim",
      "Kaiser-Yang/blink-cmp-dictionary",
    },
    opts = function()
      return require("configs.blink").opts
    end,
  },

  -- Debugging
  {
    "mfussenegger/nvim-dap",
  },
  {
    "rcarriga/nvim-dap-ui",
    event = "VeryLazy",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require "dap"
      local dapui = require "dapui"
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "leoluz/nvim-dap-go",
    ft = "go",
    dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
    config = function(_, opts)
      require("dap-go").setup(opts)
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" },
    config = function(_, _)
      local path = "~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(path)
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {},
    },
  },

  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "alfaix/neotest-gtest",
    },
    lazy = false,
    config = function()
      require "configs.neotest"
    end,
  },
  {
    "andythigpen/nvim-coverage",
    version = "*",
    config = function()
      require("coverage").setup {
        auto_reload = true,
      }
    end,
  },

  -- Languages
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
      vim.g.rust_clip_command = "xclip -selection clipboard -i"
    end,
  },
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      crates.show()
    end,
  },
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
  },
  {
    "NoahTheDuke/vim-just",
    event = { "BufReadPre", "BufNewFile" },
    ft = { "\\cjustfile", "*.just", ".justfile" },
  },

  -- AI Tooling
  {
    "zbirenbaum/copilot.lua",
    lazy = false,
    opts = function()
      return require "configs.copilot"
    end,
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    config = true,
    lazy = false, -- Otherwise it won't load
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "j-hui/fidget.nvim",
    },
    opts = function()
      return require("configs.codecompanion").opts
    end,
    init = function()
      vim.g.codecompanion_auto_tool_mode = true
      require("configs.fidget-spinner"):init()
    end,
  },

  -- Misc
  {
    "stevearc/oil.nvim",
    opts = require "configs.oil-config",
    config = function(_, opts)
      require("oil").setup(opts)
    end,
    keys = {
      { "-",        "<Cmd>Oil<CR>",         mode = "n", desc = "Open parent directory" },
      { "<space>-", "<Cmd>Oil --float<CR>", mode = "n", desc = "Open parent directory in floating window" },
    },
    -- Cannot be lazy loaded because otherwise it won't open
    lazy = false,
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
}
