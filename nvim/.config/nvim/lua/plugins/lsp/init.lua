return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" }, -- IMPORTANT: load before buffers
  dependencies = {
    { "mason-org/mason.nvim", opts = {} },
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    ---------------------------------------------------------------------------
    -- on_attach + keymaps + format-on-save (avoid double formatting)
    ---------------------------------------------------------------------------
    local function on_attach(client, bufnr)
      local opts = { buffer = bufnr, noremap = true, silent = true }

      local ok_telescope, builtin = pcall(require, "telescope.builtin")
      if ok_telescope then
        vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
        vim.keymap.set("n", "gr", builtin.lsp_references, opts)
        vim.keymap.set("n", "<leader>/", builtin.lsp_document_symbols, opts)
      else
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      end

      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
      vim.keymap.set("n", "gT", vim.lsp.buf.type_definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

      vim.keymap.set("n", "gl", function()
        vim.diagnostic.open_float({ border = "rounded" })
      end, { buffer = bufnr, desc = "Show diagnostics (float)" })

      vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

      if client.supports_method("textDocument/formatting") then
        local group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false })
        vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.format()
          end,
        })
      end
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")

        on_attach(client, args.buf)
      end,
    })

    local capabilities
    local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_lsp.default_capabilities()
    else
      capabilities = vim.lsp.protocol.make_client_capabilities()
    end

    require("mason-lspconfig").setup({
      ensure_installed = { "vue_ls", "vtsls", "jsonls", "lua_ls", "gopls", "clangd", "hyprls" },
    })

    ---------------------------------------------------------------------------
    -- Shared paths / root
    ---------------------------------------------------------------------------
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"

    local function cmd_for(exe, extra)
      extra = extra or {}
      local p = (vim.fn.executable(exe) == 1) and exe or (mason_bin .. "/" .. exe)
      return vim.list_extend({ p }, extra)
    end

    local function root_dir(fname)
      return vim.fs.root(fname, { "package.json", "tsconfig.json", "jsconfig.json", ".git" })
          or vim.fs.dirname(fname)
    end

    local function root_dir_cb(bufnr, on_dir)
      local fname = vim.api.nvim_buf_get_name(bufnr)
      local dir = root_dir(fname)
      if dir then on_dir(dir) end
    end

    local ok_schemastore, schemastore = pcall(require, "schemastore")

    ---------------------------------------------------------------------------
    -- Native LSP configs
    ---------------------------------------------------------------------------

    local vue_language_server_path = vim.fn.expand '$MASON/packages' ..
        '/vue-language-server' .. '/node_modules/@vue/language-server'
    local tsserver_filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' }
    local vue_plugin = {
      name = '@vue/typescript-plugin',
      location = vue_language_server_path,
      languages = { 'vue' },
      configNamespace = 'typescript',
    }
    local vtsls_config = {
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = {
              vue_plugin,
            },
          },
        },
      },
      filetypes = tsserver_filetypes,
    }

    local vue_ls_config = {}


    local tinymist_config = {
      cmd = { "tinymist" },
      filetypes = { "typst" },

      settings = {

      }
    }


    vim.lsp.config('vtsls', vtsls_config)
    vim.lsp.config('vue_ls', vue_ls_config)
    vim.lsp.config('tinymist', tinymist_config)
    vim.lsp.enable({ 'vtsls', 'vue_ls', 'tinymist' })


    vim.lsp.config("jsonls", {
      cmd = cmd_for("vscode-json-language-server", { "--stdio" }),
      capabilities = capabilities,
      root_dir = root_dir_cb,
      settings = {
        json = {
          schemas = ok_schemastore and schemastore.json.schemas() or {},
          validate = { enable = true },
        },
      },
    })

    vim.lsp.config("lua_ls",
      { cmd = cmd_for("lua-language-server"), capabilities = capabilities, root_dir = root_dir_cb })
    vim.lsp.config("gopls", { cmd = cmd_for("gopls"), capabilities = capabilities, root_dir = root_dir_cb })
    vim.lsp.config("clangd", { cmd = cmd_for("clangd"), capabilities = capabilities, root_dir = root_dir_cb })
    vim.lsp.config("hyprls", { cmd = cmd_for("hyprls"), capabilities = capabilities, root_dir = root_dir_cb })

    ---------------------------------------------------------------------------
    -- Enable
    ---------------------------------------------------------------------------
    vim.lsp.enable({
      "vtsls",
      "vue_ls",
      "jsonls",
      "lua_ls",
      "gopls",
      "clangd",
      "hyprls",
    })
  end,
}
