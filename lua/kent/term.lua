-- Terminal Management Configuration
-- Place this in your init.lua or in lua/terminal.lua and require it

-- Variables to store terminal buffers
local terminals = {}

-- Function to create window title
local function get_terminal_title(number)
  return ' Terminal ' .. number .. ' '
end

-- Function to close terminal window
function Close_terminal_window()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_hide(win)
end

-- Function to create a new terminal or toggle existing one
local function create_or_toggle_terminal(terminal_number)
  local target_terminal = terminal_number or 1

  if terminals[target_terminal] and vim.api.nvim_buf_is_valid(terminals[target_terminal]) then
    local win = vim.fn.bufwinnr(terminals[target_terminal])
    if win ~= -1 then
      -- Terminal is visible, hide it
      vim.cmd(win .. 'hide')
    else
      -- Terminal exists but is hidden, show it
      local buf = terminals[target_terminal]
      -- Create new window with rounded borders
      local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        width = math.floor(vim.o.columns * 0.8),
        height = 15,
        row = vim.o.lines - 18,
        col = math.floor(vim.o.columns * 0.1),
        title = get_terminal_title(target_terminal),
        title_pos = 'center',
      }
      local win = vim.api.nvim_open_win(buf, true, win_opts)
      vim.cmd 'startinsert'
    end
  else
    -- Create new terminal
    local buf = vim.api.nvim_create_buf(false, true)
    local win_opts = {
      relative = 'editor',
      style = 'minimal',
      border = 'rounded',
      width = math.floor(vim.o.columns * 0.8),
      height = 15,
      row = vim.o.lines - 18,
      col = math.floor(vim.o.columns * 0.1),
      title = get_terminal_title(target_terminal),
      title_pos = 'center',
    }
    local win = vim.api.nvim_open_win(buf, true, win_opts)
    vim.fn.termopen(vim.o.shell)
    terminals[target_terminal] = buf
    vim.cmd 'startinsert'
  end
end

-- Set up keymappings
vim.keymap.set('n', '<C-t><C-t>', function()
  create_or_toggle_terminal()
end, { silent = true })
vim.keymap.set('t', '<C-t><C-t>', function()
  vim.cmd 'stopinsert'
  Close_terminal_window()
end, { silent = true })

-- Set up number keybindings (1-9)
for i = 1, 9 do
  vim.keymap.set('n', string.format('<C-t>%d', i), function()
    create_or_toggle_terminal(i)
  end, { silent = true })
  vim.keymap.set('t', string.format('<C-t>%d', i), function()
    vim.cmd 'stopinsert'
    create_or_toggle_terminal(i)
  end, { silent = true })
end

-- Terminal-specific settings
vim.cmd [[
    augroup TerminalSettings
        autocmd!
        " Enable insert mode when entering terminal
        autocmd TermOpen * startinsert
        " Disable line numbers in terminal
        autocmd TermOpen * setlocal nonumber norelativenumber
        " Keep terminal buffer when closing window
        autocmd TermOpen * setlocal bufhidden=hide
    augroup END
]]

-- Set up terminal keybindings
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    -- Map Esc to exit terminal mode and close window
    vim.api.nvim_buf_set_keymap(0, 't', '<Esc>', '<C-\\><C-n>:lua Close_terminal_window()<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 't', '<Esc><Esc>', '<C-\\><C-n>:lua Close_terminal_window()<CR>', { noremap = true, silent = true })
  end,
})

-- Optional: Add highlight group for terminal window
vim.cmd [[
    highlight FloatBorder guifg=#80a0ff
]]
