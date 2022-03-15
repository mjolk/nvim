vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0
local g = vim.g
local cmd = vim.cmd
local o, wo, bo = vim.o, vim.wo, vim.bo
local utils = require 'utils'
local opt = utils.opt
local autocmd = utils.autocmd
local map = utils.map
-- Leader/local leader
g.mapleader = [[,]]
g.maplocalleader = [[,]]

-- Skip some remote provider loading
g.loaded_python_provider = 0
g.python_host_prog = '/usr/bin/python2'
g.python3_host_prog = '/usr/bin/python'
g.node_host_prog = '/usr/bin/neovim-node-host'

-- Settings
local buffer = { o, bo }
local window = { o, wo }
opt('textwidth', 100, buffer)
opt('scrolloff', 7)
opt('wildignore', '*.o,*~,*.pyc,*/node_modules/*,*.so,*.swp,*.zip,*/vendor/*')
opt('wildmode', 'longest,full')
opt('whichwrap', vim.o.whichwrap .. '<,>,h,l')
opt('inccommand', 'nosplit')
opt('lazyredraw', true)
opt('showmatch', true)
opt('ignorecase', true)
opt('smartcase', true)
opt('tabstop', 2, buffer)
opt('softtabstop', 2, buffer)
opt('expandtab', true, buffer)
opt('smarttab', true)
opt('shiftwidth', 2, buffer)
opt('number', true, window)
-- opt('relativenumber', true, window)
opt('smartindent', true, buffer)
opt('laststatus', 2)
opt('showmode', false)
opt('shada', [['20,<50,s10,h,/100]])
opt('hidden', true)
opt('shortmess', o.shortmess .. 'c')
opt('joinspaces', false)
-- opt('guicursor', [[n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50]])
opt('updatetime', 500)
-- opt('conceallevel', , window)
opt('concealcursor', 'nc', window)
opt('previewheight', 5)
opt('undofile', true, buffer)
opt('synmaxcol', 500, buffer)
opt('display', 'msgsep')
opt('cursorline', true, window)
opt('modeline', false, buffer)
opt('mouse', 'nivh')
-- opt('signcolumn', 'yes:1', window)

-- Colorscheme
opt('termguicolors', true)
opt('background', 'dark')
-- cmd [[colorscheme gruvbox-material]]
cmd [[colorscheme inkpot2]]

cmd [[ doautocmd User ActuallyEditing ]]
-- Keybindings
local silent = { silent = true }
-- Disable annoying F1 binding
map('', '<f1>', '<cmd>FloatermToggle<cr>')

-- Yank to clipboard
map({ 'n', 'v' }, 'y+', '<cmd>set opfunc=util#clipboard_yank<cr>g@', silent)

require 'plugins'


vim.lsp.set_log_level("debug")
