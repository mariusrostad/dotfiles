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

vim.o.number = true
vim.o.relativenumber = true

vim.o.scrolloff = 15

vim.o.cursorline = true
vim.o.cursorlineopt = 'number' -- only highlight the line number

return {}
