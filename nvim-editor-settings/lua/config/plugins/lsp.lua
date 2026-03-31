return { -- LSP Configuration & Plugins
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
        map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
        map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
        map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
        map("K", vim.lsp.buf.hover, "Hover Documentation")
        map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
      callback = function(event)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event.buf }
      end,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    local function resolve_omnisharp_cmd()
      local mason_omnisharp = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "packages", "omnisharp", "OmniSharp")
      if vim.fn.filereadable(mason_omnisharp) == 1 and vim.fn.executable(mason_omnisharp) == 1 then
        return { mason_omnisharp }
      end

      local executable = vim.fn.exepath "OmniSharp"
      if executable ~= "" then
        return { executable }
      end

      executable = vim.fn.exepath "omnisharp"
      if executable ~= "" then
        return { executable }
      end

      local dll = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "packages", "omnisharp", "libexec", "OmniSharp.dll")
      if vim.fn.filereadable(dll) == 1 and vim.fn.executable "dotnet" == 1 then
        return { "dotnet", dll }
      end

      return nil
    end

    local servers = {
      pyright = {},
      rust_analyzer = {},
      html = {},
      ruff = {},
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      omnisharp = {
        cmd = resolve_omnisharp_cmd(),
        enable_ms_build_load_projects_on_demand = false,
        enable_editorconfig_support = true,
        enable_roslyn_analysers = true,
        enable_import_completion = true,
        organize_imports_on_format = true,
        enable_decompilation_support = true,
        analyze_open_documents_only = false,
        filetypes = { "cs", "vb", "csproj", "sln", "slnx", "props", "csx", "targets" },
      },
    }

    require("mason").setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua",
      "prettier",
      "black",
      "html-lsp",
      "rustfmt",
    })
    require("mason-tool-installer").setup { ensure_installed = ensure_installed }

    require("mason-lspconfig").setup {
      automatic_installation = false,
    }

    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
      if server_name ~= "omnisharp" or server.cmd ~= nil then
        require("lspconfig")[server_name].setup(server)
      end
    end
  end,
}
