local telescope = require 'telescope'
telescope.setup {
  defaults = {
    layout_config= {
      horizontal = { width = 0.7 },
      vertical = { width  = 0.7 },
    },
    layout_strategy = 'horizontal',
    scroll_strategy = 'cycle',
  },
  extensions = {
    frecency = { workspaces = { exo = '/home/mjolk/godev' } },
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = 'smart_case',
    },
  },
  pickers = {
    lsp_references = { theme = 'ivy' },
    lsp_code_actions = { theme = 'ivy' },
    lsp_definitions = { theme = 'ivy' },
    lsp_implementations = { theme = 'ivy' },
    buffers = {
      sort_lastused = true,
      previewer = false,
    },
  },
}

-- Extensions
telescope.load_extension 'frecency'
telescope.load_extension 'fzf'
