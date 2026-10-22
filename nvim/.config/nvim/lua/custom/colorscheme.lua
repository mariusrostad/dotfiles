-- The single place where the colorscheme is chosen.
-- Theme plugins are only installed in `custom/plugins/*`; change the name below to switch.
local colorscheme = 'catppuccin-nvim'

local ok, err = pcall(vim.cmd.colorscheme, colorscheme)
if not ok then
  vim.notify(('Failed to load colorscheme %s:\n%s'):format(colorscheme, err), vim.log.levels.WARN)
end
