return require('packer').startup(function()
  -- Packer
  use 'wbthomason/packer.nvim'

  --  use 'lewis6991/impatient.nvim'
  use 'nathom/filetype.nvim'

  -- Async building & commands
  use { 'tpope/vim-dispatch', cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } }

  -- Registers
  -- use 'junegunn/vim-peekaboo'

  use 'mhinz/vim-sayonara'

  -- Movement
  use { 'chaoren/vim-wordmotion', 'justinmk/vim-sneak' }

  -- Quickfix
  use { 'Olical/vim-enmasse', cmd = 'EnMasse' }
  use 'kevinhwang91/nvim-bqf'

  -- Indentation tracking
  -- use 'lukas-reineke/indent-blankline.nvim'

   -- use "lukas-reineke/lsp-format.nvim"

  -- Wrapping/delimiters
  use {
    'machakann/vim-sandwich',
    { 'andymass/vim-matchup', setup = [[require('matchup')]], event = 'User ActuallyEditing' },
  }

  -- Search
  use 'romainl/vim-cool'

  -- Prettification
  use 'junegunn/vim-easy-align'

  -- Text objects
  use 'wellle/targets.vim'

  -- C++
  use 'p00f/clangd_extensions.nvim'

  use {
    'windwp/nvim-autopairs',
    config = function()
      require('nvim-autopairs').setup()
    end,
  }

  -- Search
  use {
    {
      'nvim-telescope/telescope.nvim',
      requires = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
      },
      wants = {
        'popup.nvim',
        'plenary.nvim',
        'telescope-frecency.nvim',
        'telescope-fzf-native.nvim',
      },
      setup = [[require('telescope_setup')]],
      config = [[require('telescope_config')]],
      cmd = 'Telescope',
      module = 'telescope',
    },
    {
      'nvim-telescope/telescope-frecency.nvim',
      after = 'telescope.nvim',
      requires = 'tami5/sqlite.lua',
    },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      run = 'make',
    },
  }

  -- Completion and linting
  use {
    'neovim/nvim-lspconfig',
    'nvim-lua/lsp-status.nvim',
    'folke/trouble.nvim',
    'ray-x/lsp_signature.nvim',
    'kosayoda/nvim-lightbulb',
  }

  -- Highlights
  use {
    'nvim-treesitter/nvim-treesitter',
    requires = {
      'nvim-treesitter/nvim-treesitter-refactor',
      'RRethy/nvim-treesitter-textsubjects',
    },
    run = ':TSUpdate',
    config = [[require('treesitter_config')]]
  }

  -- Pretty symbols
  use 'kyazdani42/nvim-web-devicons'

  use {
    "rafamadriz/friendly-snippets",
    requires = {
      'L3MON4D3/LuaSnip',
    }
  }

  -- Completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'L3MON4D3/LuaSnip',
      { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      'hrsh7th/cmp-nvim-lsp',
      {'hrsh7th/cmp-nvim-lsp-signature-help', after = 'nvim-cmp'},
      { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
      { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      'lukas-reineke/cmp-under-comparator',
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    },
    config = [[require('cmp_config')]],
    setup = [[require('lsp_setup')]],
    event = 'InsertEnter *',
  }


  -- Undo tree
  use {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    config = [[vim.g.undotree_SetFocusWhenToggle = 1]],
  }
  -- Git
  use {
    { 'tpope/vim-fugitive', cmd = { 'Git', 'Gstatus', 'Gblame', 'Gpush', 'Gpull' }, disable = true },
    {
      'lewis6991/gitsigns.nvim',
      requires = { 'nvim-lua/plenary.nvim' },
      config = [[require('gitsigns_config')]],
    },
    { 'TimUntersberger/neogit', cmd = 'Neogit', config = [[require('neogit_config')]] },
  }

  -- Debugger
  use {
    {
      'mfussenegger/nvim-dap',
      setup = [[require('dap_setup')]],
      config = [[require('dap_config')]],
      requires = 'jbyuki/one-small-step-for-vimkind',
      wants = 'one-small-step-for-vimkind',
      module = 'dap',
    },
    {
      'rcarriga/nvim-dap-ui',
      requires = 'nvim-dap',
      after = 'nvim-dap',
      config = function()
        require('dapui').setup()
      end,
    },
  }

  -- Endwise
  -- use 'tpope/vim-endwise'
  use 'RRethy/nvim-treesitter-endwise'

  -- Buffer management
  use {
    'akinsho/bufferline.nvim',
    requires = 'kyazdani42/nvim-web-devicons',
    config = [[require('bufferline_setup')]],
    -- event = 'User ActuallyEditing',
  }

  use {
    'ray-x/go.nvim',
    requires = {
      'mfussenegger/nvim-dap',
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'ray-x/guihua.lua'
    },
    config = [[require('go_setup')]],
  }

  -- use { 'jose-elias-alvarez/null-ls.nvim', requires = { 'nvim-lua/plenary.nvim', 'neovim/nvim-lspconfig' } }

end)
