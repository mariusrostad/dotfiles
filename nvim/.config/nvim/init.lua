vim.g.mapleader = " "

-- option
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.signcolumn = "yes"
vim.o.undofile = true
vim.o.autoread = true
vim.o.laststatus = 3
vim.o.cmdheight = 0
vim.o.mouse = 'a'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.confirm = true
vim.opt.scrolloff = 2
vim.opt.undofile = true
vim.opt.colorcolumn = '80'
-- vim.api.nvim_create_autocmd('Filetype', { pattern = 'rust', command = 'set colorcolumn=100' })
vim.opt.listchars = 'tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•'
vim.g.have_nerd_font = true
-- Sync clipboard between OS and Neovim.
--	Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-------------------------------------------------------------------------------
-- Keymaps
-------------------------------------------------------------------------------

-- Write and quit
vim.keymap.set("n", "<leader>fs", ":w<cr>", { silent = true })
-- vim.keymap.set("n", "<leader>q", ":q<cr>", { silent = true })

-- Redo
vim.keymap.set("n", "U", "<c-r>", { silent = true })

-- Swap between split buffers
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>", { silent = true, desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>", { silent = true, desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>", { silent = true, desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>", { silent = true, desc = "Move to right split" })

-- Clear highlights on search when pressing <Esc> in normal mode
--	See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },

  -- Can switch between these as you prefer
  virtual_text = true, -- Text shows up at the end of the line
  virtual_lines = false, -- Text shows up underneath the line, with virtual lines

  -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float {
        bufnr = bufnr,
        scope = 'cursor',
        focus = false,
      }
    end,
  },
}

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-------------------------------------------------------------------------------
-- Colorscheme
-------------------------------------------------------------------------------
vim.cmd.colorscheme("catppuccin")
-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })

-------------------------------------------------------------------------------
-- LSP
-------------------------------------------------------------------------------
vim.lsp.enable({ "lua_ls", "tsgo" })
vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

-- Make the popup behave like a plugin-based completion menu
vim.o.completeopt = 'menu,menuone,noselect,popup,fuzzy'

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or not client:supports_method('textDocument/completion') then
      return
    end

		-- Configuration that enables or disables automatic Lsp completion hints.
		-- I've turned it off so I can focus. Use the keybinding defined underneeth
		-- to trigger the poppup.
    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })

		-- Simple keymapping that trigger the Lsp completion dialog
    vim.keymap.set('i', '<C-Space>', function()
      vim.lsp.completion.get()
    end, { buffer = ev.buf, desc = 'Trigger LSP completion' })
  end,
})

-- Makes sure that the Lsp completion only persists to the buffer once chosen
-- and not becuase it's at the first element in the list.
vim.cmd("set completeopt+=noselect")

-------------------------------------------------------------------------------
-- Diagnostics
-------------------------------------------------------------------------------
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { silent = true })

-- netrw
vim.g.netrw_liststyle = 3 -- tree view
vim.g.netrw_banner = 0 -- hide the top banner
vim.g.netrw_winsize = 25 -- fix the left split width
vim.g.netrw_browse_split = 0 -- open files in the previous window
vim.g.netrw_altfile = 1 -- keep the alternate file correct

vim.keymap.set("n", "<leader>e", ":Lexplore<cr>", { silent = true })

-- netrw's built-in `%` opens new files in the netrw window instead of
-- respecting `netrw_browse_split`. Override it to open in the previous window.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function()
		vim.keymap.set("n", "%", function()
			local fname = vim.fn.input("Enter filename: ")
			if fname == "" then
				return
			end

			local dir = vim.b.netrw_curdir or vim.fn.getcwd()
			local path = dir .. "/" .. fname

			if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
				vim.notify("Already exists: " .. fname, vim.log.levels.WARN)
				return
			end

			if fname:match("/$") then
				vim.fn.mkdir(path, "p")
				vim.cmd("edit")
			else
				local f = io.open(path, "w")
				if not f then
					vim.notify("Failed to create: " .. fname, vim.log.levels.ERROR)
					return
				end
				f:close()

				local escaped = vim.fn.fnameescape(path)
				if vim.fn.winnr("#") == 0 then
					vim.cmd("edit " .. escaped)
				else
					vim.cmd("wincmd p")
					vim.cmd("edit " .. escaped)
				end
			end
		end, { buffer = true, silent = true, noremap = true, desc = "Create file in previous window" })
	end,
})

-------------------------------------------------------------------------------
-- Grep
-------------------------------------------------------------------------------
vim.opt.grepprg = "rg --vimgrep --smart-case --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.keymap.set("n", "<leader>fg", function()
	vim.ui.input({ prompt = "Grep: " }, function(pattern)
		if pattern then
			vim.cmd("silent grep! " .. vim.fn.fnameescape(pattern))
			vim.cmd("copen")
		end
	end)
end, { silent = true })

-------------------------------------------------------------------------------
-- Statusline
-------------------------------------------------------------------------------
local pms = vim.api.nvim_get_hl(0, { name = "PmenuSel", link = false })
local dir = vim.api.nvim_get_hl(0, { name = "Directory", link = false })
local vis = vim.api.nvim_get_hl(0, { name = "Visual", link = false })
vim.api.nvim_set_hl(0, "StlMode", { fg = pms.fg, bg = vis.bg })
vim.api.nvim_set_hl(0, "StlGit", { fg = dir.fg, bg = pms.bg })

local modes = {
	n = "NORMAL",
	i = "INSERT",
	v = "VISUAL",
	V = "V-LINE",
	["\22"] = "V-BLOCK",
	c = "COMMAND",
	t = "TERMINAL",
	R = "REPLACE",
	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",
}

function _G._statusline()
	local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
	local branch = vim.b.git_branch and "%#StlGit# " .. vim.b.git_branch .. " %*" or ""
	local path = vim.b.rel_path or "%f"

	local diag = ""
	local counts = vim.diagnostic.count(0) or {}
	local labels = { " ", " ", " ", " " }
	local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
	for i = 1, 4 do
		if counts[i] and counts[i] > 0 then
			diag = diag .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
		end
	end

	return "%#StlMode# " .. mode .. " %*" .. branch .. " " .. path .. "%=" .. diag .. vim.bo.filetype .. " %l:%c"
end

vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		local root = vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"):gsub("%s+$", "")
		if root ~= "" then
			vim.b.git_branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("%s+$", "")
			vim.b.rel_path = vim.fn.expand("%:p"):sub(#root + 2)
		else
			vim.b.git_branch = nil
			vim.b.rel_path = vim.fn.expand("%:p:~")
		end
	end,
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		vim.cmd("redrawstatus!")
	end,
})

vim.o.statusline = "%!v:lua._statusline()"

-------------------------------------------------------------------------------
-- Autocommands
-------------------------------------------------------------------------------

-- Highlight selection on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
	pattern = "*",
	desc = "highlight selection on yank",
	callback = function()
		vim.highlight.on_yank({ timeout = 200, visual = true })
	end,
})

-- Restore cursor to file position in previous editing session
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			vim.api.nvim_win_set_cursor(0, mark)
			-- defer centering slightly so it's applied after render
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})
