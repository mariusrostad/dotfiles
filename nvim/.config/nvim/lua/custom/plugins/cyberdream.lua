return {
  'scottmckendry/cyberdream.nvim',
  lazy = false,
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'cyberdream'
  end,
  config = function()
    require('cyberdream').setup {
      -- Set light or dark variant
      variant = 'default', -- use "light" for the light variant. Also accepts "auto" to set dark or light colors based on the current value of `vim.o.background`

      -- Enable transparent background
      transparent = true,

      -- Reduce the overall saturation of colours for a more muted look
      saturation = 1, -- accepts a value between 0 and 1. 0 will be fully desaturated (greyscale) and 1 will be the full color (default)

      -- Enable italics comments
      italic_comments = false,

      -- Replace all fillchars with ' ' for the ultimate clean look
      hide_fillchars = false,

      -- Apply a modern borderless look to pickers like Telescope, Snacks Picker & Fzf-Lua
      borderless_pickers = false,

      -- Set terminal colors used in `:terminal`
      terminal_colors = true,

      -- Improve start up time by caching highlights. Generate cache with :CyberdreamBuildCache and clear with :CyberdreamClearCache
      cache = false,

      -- Disable or enable colorscheme extensions
      extensions = {
        telescope = true,
        notify = true,
        mini = true,
      },
    }

    -- Add a custom keybinding to toggle the colorscheme
    vim.api.nvim_set_keymap('n', '<leader>tt', ':CyberdreamToggleMode<CR>', { noremap = true, silent = true })
  end,
}
