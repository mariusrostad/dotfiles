return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set('n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gd', ':Gdiff<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true })

    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gs', ':Git<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gc', ':Git commit<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gp', ':Git push<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gl', ':Git log<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gd', ':Gdiff<CR>', { noremap = true, silent = true })
    -- vim.api.nvim_buf_set_keymap(buffnr, 'n', '<leader>gb', ':Git blame<CR>', { noremap = true, silent = true })
  end,
}
