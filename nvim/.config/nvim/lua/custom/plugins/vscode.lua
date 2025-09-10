return {
  'Mofiqul/vscode.nvim',
  priority = 1000,
  init = function()
    -- vim.cmd.colorscheme 'vscode'
  end,
  config = function()
    require('vscode').setup {
      -- style = 'light'
      transparent = true,
      terminal_colors = true,
    }
  end,
}
