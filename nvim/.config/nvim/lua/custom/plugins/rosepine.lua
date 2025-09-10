return {
  'rose-pine/neovim',
  name = 'rose-pine',
  priority = 1000,
  init = function()
    -- vim.cmd 'colorscheme rose-pine'
  end,
  config = function()
    require('rose-pine').setup {
      extend_background_behind_borders = true,
      styles = {
        transparency = true,
      },
    }
  end,
}
