return {
  'akinsho/toggleterm.nvim',
  version = 'v2.8.0',
  config = function()
    require('toggleterm').setup {}
    local Terminal = require('toggleterm.terminal').Terminal
    local lazygit = Terminal:new {
      cmd = 'lazygit',
      hidden = true,
      direction = 'float',
      float_opts = {
        boarder = 'double',
      },
    }

    vim.keymap.set('n', '<leader>gg', function()
      lazygit:toggle()
    end, { desc = 'Trouble toggle' })
  end,
}
