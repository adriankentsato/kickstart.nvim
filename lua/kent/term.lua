local terminals = {}
local current_term = nil

local function open_floating_window(opts)
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  local title = nil

  if opts.buf and vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  if opts.index then
    title = " Kent's Terminal #" .. opts.index .. ' '
  else
    title = " Kent's Terminal "
  end

  local win_config = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local function open_term(opts)
  local index = opts.args ~= '' and tonumber(opts.args) or 1
  local current = terminals[index] or {
    buf = -1,
    win = -1,
  }

  if current_term ~= nil and current_term > 0 and vim.api.nvim_win_is_valid(terminals[current_term].win) then
    -- If the current terminal is not the index then we will close it
    vim.api.nvim_win_hide(terminals[current_term].win)
  end

  if index > 0 and current_term == nil then
    -- Check if the current window is already up
    if vim.api.nvim_win_is_valid(current.win) then
      vim.api.nvim_win_hide(current.win) -- Close that window
      current_term = nil
    else
      -- We'll create a new window with the buffer if available
      terminals[index] = open_floating_window { buf = current.buf, index = index }
      current_term = index

      if vim.bo[terminals[index].buf].buftype ~= 'terminal' then
        vim.cmd.terminal()
      end
      vim.cmd 'startinsert'
    end
  else
    current_term = nil
  end
end

vim.api.nvim_create_user_command('Kenterminal', open_term, { nargs = '?' })

-- Set up keymappings
vim.keymap.set({ 'n', 't' }, '<C-t><C-t>', function()
  open_term { args = '1' }
end, { silent = true, desc = 'Open/Close Terminal' })

vim.keymap.set('t', '<esc><esc>', '<c-\\><c-n>:Kenterminal -1<CR>', { silent = true })

for i = 1, 9 do
  vim.keymap.set('n', string.format('<C-t>%d', i), function()
    vim.cmd 'stopinsert'
    open_term { args = string.format('%s', (i or '')) }
  end, { silent = true, desc = string.format('Open Terminal %d', i) })
end
