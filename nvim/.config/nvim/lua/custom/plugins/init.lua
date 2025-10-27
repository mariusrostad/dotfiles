-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
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

-- Trouble settings
vim.keymap.set('n', '<leader>xx', function()
  require('trouble').toggle()
end, { desc = 'Trouble toggle' })
vim.keymap.set('n', '<leader>xw', function()
  require('trouble').toggle 'workspace_diagnostics'
end, { desc = 'Trouble workspace_diagnostics' })
vim.keymap.set('n', '<leader>xd', function()
  require('trouble').toggle 'document_diagnostics'
end, { desc = 'Trouble document_diagnostics' })
vim.keymap.set('n', '<leader>xq', function()
  require('trouble').toggle 'quickfix'
end, { desc = 'Trouble quickfix' })
vim.keymap.set('n', '<leader>xl', function()
  require('trouble').toggle 'loclist'
end, { desc = 'Trouble loclist' })
vim.keymap.set('n', 'gR', function()
  require('trouble').toggle 'lsp_references'
end, { desc = 'Trouble lsp_references' })

vim.wo.number = true
vim.wo.relativenumber = true

vim.o.scrolloff = 15

vim.opt.cursorline = true
vim.opt.cursorlineopt = 'number' -- only highlight the line number

return {}
