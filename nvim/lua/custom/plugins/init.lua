-- Loaded from init.lua via `require 'custom.plugins'`.
-- Options and keymaps live here; each plugin has its own module, required below.
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Jump panel left' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Jump panel down' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Jump panel up' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Jump panel right' })

-- vim.keymap.set('n', '<C-e>', '<Cmd>Neotree toggle<CR>', { desc = 'Neotree toggle' })
vim.keymap.set('n', '<C-s>', '<Cmd>write<CR>', { desc = 'Save' })
vim.keymap.set('n', '<leader>fs', '<Cmd>write<CR>', { desc = '[F]ile Save' })

-- Rounded corners are important!
vim.o.winborder = 'rounded'
vim.diagnostic.config {
  float = {
    border = 'rounded',
  },
}

vim.o.number = true
vim.o.relativenumber = true

vim.o.scrolloff = 15

vim.o.cursorline = true
vim.o.cursorlineopt = 'number' -- only highlight the line number

vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open diagnostics [D]iagnostic list' })

-- Order matters: snacks needs to be set up before lualine uses `Snacks`,
-- and fugitive's <leader>g* maps override snacks'.
require 'custom.plugins.base16'
require 'custom.plugins.catpuccin'
require 'custom.plugins.cyberdream'
require 'custom.plugins.rosepine'
require 'custom.plugins.vscode'
require 'custom.plugins.gruvbox'
require 'custom.plugins.snacks'
require 'custom.plugins.lualine'
require 'custom.plugins.trouble'
require 'custom.plugins.todo-comments'
require 'custom.plugins.fugitive'
require 'custom.plugins.copilot'
require 'custom.plugins.grafana-lsp'

-- Apply the colorscheme once every theme plugin is installed.
require 'custom.colorscheme'
