-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"
local blink_capabilities = require("blink.cmp").get_lsp_capabilities()

-- Merge blink capabilities with nvlsp capabilities and apply to every server.
-- defaults() already wires on_attach (via an LspAttach autocmd) and on_init globally.
local capabilities = vim.tbl_deep_extend("force", nvlsp.capabilities, blink_capabilities)
vim.lsp.config("*", { capabilities = capabilities })

-- lsps that just use nvim-lspconfig's shipped defaults
vim.lsp.enable { "html", "cssls", "svelte", "ts_ls", "tailwindcss", "pyright" }

vim.lsp.config("emmet_ls", {
  filetypes = {
    "css",
    "eruby",
    "html",
    "javascript",
    "javascriptreact",
    "less",
    "sass",
    "scss",
    "svelte",
    "pug",
    "typescriptreact",
    "templ",
    "vue",
  },
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ["bem.enabled"] = true,
      },
    },
  },
})
vim.lsp.enable "emmet_ls"

local c = require "configs.local_lspconfig"

-- Use Neovim 0.11+ native LSP API for clangd (avoids conflicts with lspconfig)
-- Each project with .clangd-docker gets its own clangd instance in the correct Docker container
vim.lsp.config("clangd", {
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
  -- Dynamic root_dir per buffer - find .clangd-docker to determine project root
  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == "" then return end
    -- Find .clangd-docker walking up from buffer's directory
    local root = vim.fs.root(bufnr, { ".clangd-docker", ".clangd", "compile_commands.json" })
    if root then
      on_dir(root)
    end
    -- Don't call on_dir if no root found - prevents attaching to random files
  end,
  -- Dynamic cmd - spawns clangd in the correct Docker container based on root_dir
  cmd = function(dispatchers, config)
    local docker_script = c.find_clangd_docker_from(config.root_dir or vim.fn.getcwd())
    local cmd_args = docker_script and { docker_script } or { "clangd" }
    local extra_spawn_params = {}
    if config.root_dir then
      extra_spawn_params.env = { CLANGD_DOCKER_CWD = config.root_dir }
    end
    return vim.lsp.rpc.start(cmd_args, dispatchers, extra_spawn_params)
  end,
  -- Only reuse client if root_dir matches exactly (different Docker containers per project)
  reuse_client = function(client, config)
    return client.config.root_dir == config.root_dir
  end,
  on_attach = function(client, bufnr)
    client.server_capabilities.signatureHelpProvider = false
  end,
  capabilities = capabilities,
})
vim.lsp.enable("clangd")

-- pyright uses nvim-lspconfig's shipped defaults (enabled above).

-- gopls: the shipped config already sets cmd/filetypes/root_dir, so only the
-- extra settings need to be layered on top.
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      completeUnimported = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
})
vim.lsp.enable "gopls"
