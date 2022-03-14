local lspconfig = require 'lspconfig'
local trouble = require 'trouble'
local lsp_status = require 'lsp-status'
local null_ls = require 'null-ls'

require('clangd_extensions.config').setup {
  extensions = { inlay_hints = { only_current_line = true, show_variable_name = true } },
}

local lsp = vim.lsp
local buf_keymap = vim.api.nvim_buf_set_keymap
local cmd = vim.cmd

vim.api.nvim_command 'hi link LightBulbFloatWin YellowFloat'
vim.api.nvim_command 'hi link LightBulbVirtualText YellowFloat'

local kind_symbols = {
  Text = '  ',
  Method = '  ',
  Function = '  ',
  Constructor = '  ',
  Field = '  ',
  Variable = '  ',
  Class = '  ',
  Interface = '  ',
  Module = '  ',
  Property = '  ',
  Unit = '  ',
  Value = '  ',
  Enum = '  ',
  Keyword = '  ',
  Snippet = '  ',
  Color = '  ',
  File = '  ',
  Reference = '  ',
  Folder = '  ',
  EnumMember = '  ',
  Constant = '  ',
  Struct = '  ',
  Event = '  ',
  Operator = '  ',
  TypeParameter = '  ',
}

local sign_define = vim.fn.sign_define
sign_define('DiagnosticSignError', { text = '', numhl = 'RedSign' })
sign_define('DiagnosticSignWarn', { text = '', numhl = 'YellowSign' })
sign_define('DiagnosticSignInfo', { text = '', numhl = 'WhiteSign' })
sign_define('DiagnosticSignHint', { text = '', numhl = 'BlueSign' })
lsp_status.config {
  kind_labels = kind_symbols,
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ['start'] = { character = 0, line = vim.fn.byte2line(symbol.valueRange[1]) },
        ['end'] = { character = 0, line = vim.fn.byte2line(symbol.valueRange[2]) },
      }

      return require('lsp-status/util').in_range(cursor_pos, value_range)
    end
  end,
  current_function = false,
}

lsp_status.register_progress()
trouble.setup()
lsp.handlers['textDocument/publishDiagnostics'] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
  virtual_text = false,
  signs = true,
  update_in_insert = false,
  underline = true,
})

require('lsp_signature').setup { bind = true, handler_opts = { border = 'single' } }
local keymap_opts = { noremap = true, silent = true }
local function on_attach(client)
  lsp_status.on_attach(client)
  require('lsp_signature').on_attach { bind = true, handler_opts = { border = 'single' } }
  buf_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gd', '<cmd>lua require"telescope.builtin".lsp_definitions()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gi', '<cmd>lua require"telescope.builtin".lsp_implementations()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gS', '<cmd>lua vim.lsp.buf.signaturn_help()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gTD', '<cmd>lua vim.lsp.buf.type_definition()<CR>', keymap_opts)
  buf_keymap(0, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gr', '<cmd>lua require"telescope.builtin".lsp_references()<CR>', keymap_opts)
  buf_keymap(0, 'n', 'gA', '<cmd>lua require"telescope.builtin".lsp_code_actions()<CR>', keymap_opts)
  buf_keymap(0, 'n', ']e', '<cmd>lua vim.lsp.diagnostic.goto_next { float = true }<cr>', keymap_opts)
  buf_keymap(0, 'n', '[e', '<cmd>lua vim.lsp.diagnostic.goto_prev { float = true }<cr>', keymap_opts)

  if client.resolved_capabilities.document_formatting then
    buf_keymap(0, 'n', '<leader>p', '<cmd>lua vim.lsp.buf.formatting()<cr>', keymap_opts)
      vim.cmd([[
            augroup LspFormatting
                autocmd! * <buffer>
                autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
            augroup END
      ]])
  end

  cmd 'augroup lsp_aucmds'
  if client.resolved_capabilities.document_highlight == true then
    cmd 'au CursorHold <buffer> lua vim.lsp.buf.document_highlight()'
    cmd 'au CursorMoved <buffer> lua vim.lsp.buf.clear_references()'
  end

  cmd 'au CursorHold,CursorHoldI <buffer> lua require"nvim-lightbulb".update_lightbulb {sign = {enabled = false}, virtual_text = {enabled = true, text = ""}, float = {enabled = false, text = "", win_opts = {winblend = 100, anchor = "NE"}}}'
   cmd 'au CursorHold,CursorHoldI <buffer> lua vim.diagnostic.open_float(0, { scope = "line" })'
  cmd 'augroup END'
end

local function prefer_null_ls_fmt(client)
  client.resolved_capabilities.document_formatting = false
  client.resolved_capabilities.document_range_formatting = false
  on_attach(client)
end

local sumneko_binary_path = vim.fn.exepath('/usr/lib/lua-language-server/bin/lua-language-server')
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local servers = {
  bashls = {},
  clangd = {
    on_attach = function()
      require('clangd_extensions.inlay_hints').setup_autocmd()
      require('clangd_extensions.inlay_hints').set_inlay_hints()
      require('clangd_extensions').hint_aucmd_set_up = true
    end,
    prefer_null_ls = true,
    cmd = {
      'clangd',
      '--background-index',
      '--clang-tidy',
      '--completion-style=bundled',
      '--header-insertion=iwyu',
      '--cross-file-rename',
    },
    handlers = lsp_status.extensions.clangd.setup(),
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true,
    },
  },
  cssls = {
    cmd = { 'vscode-css-languageserver', '--stdio' },
    filetypes = { 'css', 'scss', 'less', 'sass' },
    root_dir = lspconfig.util.root_pattern('package.json', '.git'),
  },
  ghcide = {},
  html = { cmd = { 'vscode-html-languageserver', '--stdio' } },
  jsonls = { prefer_null_ls = true, cmd = { 'vscode-json-languageserver', '--stdio' } },
  julials = { settings = { julia = { format = { indent = 2 } } } },
  ocamllsp = {},
  pyright = { settings = { python = { formatting = { provider = 'yapf' } } } },
  rust_analyzer = {},
  -- sumneko_lua = function()
  --   return require('lua-dev').setup({lspconfig = {cmd = {'lua-language-server'}}})
  -- end,
  sumneko_lua = {
    cmd = { sumneko_binary_path, "-E", "/usr/lib/lua-language-server/bin/main.lua"},
    on_attach = require "lsp-format".on_attach,
    settings = {
      Lua = {
        diagnostics = { globals = { 'vim' } },
        runtime = { version = 'LuaJIT', path = runtime_path },
        workspace = {
          library = {
            [vim.fn.expand '$VIMRUNTIME/lua'] = true,
        --    [vim.fn.expand '$VIMRUNTIME/lua/vim/lsp'] = true,
          },
        },
      },
    },
  },
  texlab = {
    settings = {
      texlab = {
        chktex = { onOpenAndSave = true },
        formatterLineLength = 100,
        forwardSearch = { executable = 'zathura', args = { '--synctex-forward', '%l:1:%f', '%p' } },
      },
    },
    commands = {
      TexlabForwardSearch = {
        function()
          local pos = vim.api.nvim_win_get_cursor(0)
          local params = {
            textDocument = { uri = vim.uri_from_bufnr(0) },
            position = { line = pos[1] - 1, character = pos[2] },
          }
          lsp.buf_request(0, 'textDocument/forwardSearch', params, function(err, _, _, _)
            if err then
              error(tostring(err))
            end
          end)
        end,
        description = 'Run synctex forward search',
      },
    },
  },
  tsserver = {},
  vimls = {},
  gopls = {
   on_attach = on_attach,
   prefer_null_ls= true,
   capabilities = {
    textDocument = {
      completion = {
        completionItem = {
          commitCharactersSupport = true,
          deprecatedSupport = true,
          documentationFormat = { "markdown", "plaintext" },
          preselectSupport = true,
          insertReplaceSupport = true,
          labelDetailsSupport = true,
          snippetSupport = true,
          resolveSupport = {
            properties = {
              "documentation",
              "details",
              "additionalTextEdits",
            },
          },
        },
        contextSupport = true,
        dynamicRegistration = true,
      },
    },
  },
  filetypes = { "go", "gomod", "gohtmltmpl", "gotexttmpl" },
  message_level = vim.lsp.protocol.MessageType.Error,
  cmd = {
    "gopls", -- share the gopls instance if there is one already
    "-remote.debug=:0",
  },
  root_dir = function(fname)
    local has_lsp, lspconfig = pcall(require, "lspconfig")
    if has_lsp then
      local util = lspconfig.util
      return util.root_pattern("go.mod", ".git")(fname) or util.path.dirname(fname)
    end
  end,
  flags = { allow_incremental_sync = true, debounce_text_changes = 500 },
  settings = {
    gopls = {
      -- more settings: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
      -- flags = {allow_incremental_sync = true, debounce_text_changes = 500},
      -- not supported
      analyses = { unusedparams = true, unreachable = false, shadow = true },
      codelenses = {
        generate = true, -- show the `go generate` lens.
        gc_details = true, --  // Show a code lens toggling the display of gc's choices.
        test = true,
        tidy = true,
      },
      usePlaceholders = true,
      experimentalPostfixCompletions = true,
      experimentalUseInvalidMetadata = true,
      hoverKind = "Structured",
      completeUnimported = true,
      staticcheck = true,
      matcher = "Fuzzy",
      diagnosticsDelay = "500ms",
      experimentalWatchedFileDelay = "100ms",
      symbolMatcher = "fuzzy",
      ["local"] = "",
      gofumpt = false, -- true, -- turn on for new repos, gofmpt is good but also create code turmoils
      buildFlags = { "-tags", "integration" },
      -- buildFlags = {"-tags", "functional"}
    },
  },
}}

local client_capabilities = vim.lsp.protocol.make_client_capabilities()
client_capabilities.textDocument.completion.completionItem.snippetSupport = true
client_capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { 'documentation', 'detail', 'additionalTextEdits' },
}
client_capabilities = require('cmp_nvim_lsp').update_capabilities(client_capabilities)
client_capabilities.offsetEncoding = { 'utf-16' }

for server, config in pairs(servers) do
  if type(config) == 'function' then
    config = config()
  end

  if config.prefer_null_ls then
    if config.on_attach then
      local old_on_attach = config.on_attach
      config.on_attach = function(client, bufnr)
        old_on_attach(client, bufnr)
        prefer_null_ls_fmt(client)
      end
    else
      config.on_attach = config.on_attach and prefer_null_ls_fmt
    end
  else
    if config.on_attach then
      local old_on_attach = config.on_attach
      config.on_attach = function(client, bufnr)
        old_on_attach(client, bufnr)
        prefer_null_ls_fmt(client)
      end
    else
      config.on_attach = on_attach
    end
  end

  config.capabilities = vim.tbl_deep_extend(
    'keep',
    config.capabilities or {},
    client_capabilities,
    lsp_status.capabilities
  )

  print('capabilities', config.capabilities)

  for index, data in ipairs(config.capabilities) do
    print(index)
    for key, value in pairs(data) do
      print('\t', key, value)
    end
  end

  lspconfig[server].setup(config)
end

-- null-ls setup
local null_fmt = null_ls.builtins.formatting
local null_diag = null_ls.builtins.diagnostics
 null_ls.setup {
  sources = {
    -- null_diag.chktex,
    -- null_diag.cppcheck,
    -- null_diag.proselint,
    -- null_diag.pylint,
    -- null_diag.selene,
    -- null_diag.shellcheck,
    -- null_diag.teal,
    null_diag.golangci_lint,
    -- null_diag.vale,
    -- null_diag.vint,
    null_diag.write_good.with { filetypes = { 'markdown', 'tex' } },
    null_fmt.clang_format,
    null_fmt.cmake_format,
    null_fmt.isort,
    null_fmt.prettier,
    null_fmt.rustfmt,
    null_fmt.shfmt,
    null_fmt.stylua,
    null_fmt.trim_whitespace,
    null_fmt.yapf,
    null_fmt.gofumpt,
    null_fmt.goimports,
    null_fmt.golines,
    -- null_fmt.black
  },
  on_attach = on_attach,
} 