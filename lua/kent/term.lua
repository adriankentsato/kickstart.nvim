-- Terminal Management Configuration
-- Place this in your init.lua or in lua/terminal.lua and require it

-- Variables to store terminal buffers
local terminals = {}
local current_terminal = nil

-- Configure the terminal window appearance
local terminal_window_settings = {
  border = 'rounded',
  highlight = 'FloatBorder:Normal',
}

-- Function to create a new terminal or toggle existing one
local function create_or_toggle_terminal(terminal_number)
  if terminal_number then
    -- If terminal exists, toggle it
    if terminals[terminal_number] and vim.api.nvim_buf_is_valid(terminals[terminal_number]) then
      local win = vim.fn.bufwinnr(terminals[terminal_number])
      if win ~= -1 then
        -- Terminal is visible, hide it
        vim.cmd(win .. 'hide')
      else
        -- Terminal exists but is hidden, show it
        local buf = terminals[terminal_number]
        -- Create new window with rounded borders
        local win_opts = {
          relative = 'editor',
          style = 'minimal',
          border = 'rounded',
          width = math.floor(vim.o.columns * 0.8),
          height = 15,
          row = vim.o.lines - 18,
          col = math.floor(vim.o.columns * 0.1),
        }
        local win = vim.api.nvim_open_win(buf, true, win_opts)
        vim.cmd 'startinsert'
      end
    else
      -- Create new numbered terminal
      local buf = vim.api.nvim_create_buf(false, true)
      local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        width = math.floor(vim.o.columns * 0.8),
        height = 15,
        row = vim.o.lines - 18,
        col = math.floor(vim.o.columns * 0.1),
      }
      local win = vim.api.nvim_open_win(buf, true, win_opts)
      vim.fn.termopen(vim.o.shell)
      terminals[terminal_number] = buf
      current_terminal = terminal_number
      vim.cmd 'startinsert'
    end
  else
    -- Toggle the main terminal (Ctrl+TT)
    if current_terminal and terminals[current_terminal] and vim.api.nvim_buf_is_valid(terminals[current_terminal]) then
      local win = vim.fn.bufwinnr(terminals[current_terminal])
      if win ~= -1 then
        vim.cmd(win .. 'hide')
      else
        local buf = terminals[current_terminal]
        -- Create new window with rounded borders
        local win_opts = {
          relative = 'editor',
          style = 'minimal',
          border = 'rounded',
          width = math.floor(vim.o.columns * 0.8),
          height = 15,
          row = vim.o.lines - 18,
          col = math.floor(vim.o.columns * 0.1),
        }
        local win = vim.api.nvim_open_win(buf, true, win_opts)
        vim.cmd 'startinsert'
      end
    else
      -- Create first terminal
      local buf = vim.api.nvim_create_buf(false, true)
      local win_opts = {
        relative = 'editor',
        style = 'minimal',
        border = 'rounded',
        width = math.floor(vim.o.columns * 0.8),
        height = 15,
        row = vim.o.lines - 18,
        col = math.floor(vim.o.columns * 0.1),
      }
      local win = vim.api.nvim_open_win(buf, true, win_opts)
      vim.fn.termopen(vim.o.shell)
      terminals[1] = buf
      current_terminal = 1
      vim.cmd 'startinsert'
    end
  end
end

-- Set up keymappings
vim.keymap.set('n', '<C-t><C-t>', function()
  create_or_toggle_terminal()
end, { silent = true })

-- Set up number keybindings (1-9)
for i = 1, 9 do
  vim.keymap.set('n', string.format('<C-t>%d', i), function()
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
        " Easy escape from terminal
        autocmd TermOpen * tnoremap <buffer> <Esc> <C-\><C-n>
        " Keep terminal buffer when closing window
        autocmd TermOpen * setlocal bufhidden=hide
    augroup END
]]

-- Optional: Add highlight group for terminal window
vim.cmd [[
    highlight FloatBorder guifg=#80a0ff
]]
