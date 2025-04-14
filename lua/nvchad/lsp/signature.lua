local M = {}
local api = vim.api

local function check_triggeredChars(triggerChars)
  local cur_line = api.nvim_get_current_line()
  local pos = api.nvim_win_get_cursor(0)[2]
  local prev_char = cur_line:sub(pos - 1, pos - 1)
  local cur_char = cur_line:sub(pos, pos)

  for _, char in ipairs(triggerChars) do
    if cur_char == char or prev_char == char then
      return true
    end
  end
end

M.setup = function(client, bufnr)
  local group = api.nvim_create_augroup("LspSignature", { clear = false })
  api.nvim_clear_autocmds { group = group, buffer = bufnr }

  local triggerChars = client.server_capabilities.signatureHelpProvider.triggerCharacters

  api.nvim_create_autocmd("TextChangedI", {
    group = group,
    buffer = bufnr,
    callback = function()
      if check_triggeredChars(triggerChars) then
        local max_height = vim.fn.screenrow() == vim.o.scrolloff + 1 and vim.o.scrolloff - 1 or 8
        vim.lsp.buf.signature_help {
          anchor_bias = "above",
          focus = false,
          silent = true,
          max_height = max_height,
          max_width = math.floor(vim.o.columns * 0.4),
        }
      end
    end,
  })
end

return M
