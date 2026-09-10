-- Atalho para teste automático de arquivo '.test.ts'
--
-- <leader>tf : abre uma janela vertical ao lado + roda `npm run test -- <arquivo>`
--
-- Funciona só em .test.ts / .spec.ts; em outro arquivo avisa sobre e não abre.
--

local M = {}

-- Janela do arquivo de teste pra podermos voltar depois.
M.source_win = vim.api.nvim_get_current_win()

-- Retorna o caminho absoluto do arquivo de teste ou nil.
local function current_test_file_path()
  local filename = vim.fn.expand '%:t' -- nome só: foo.test.ts
  if filename:match '.*test%.' or filename:match '.*spec%.' then
    return vim.fn.expand '%:p' -- /abs/path/foo.test.ts
  end
  return nil
end

--- @param is_floating boolean
local function test_file(is_floating)
  local abs_path = current_test_file_path()
  if not abs_path then
    vim.notify('[Testing]: só em .test.ts / .spec.ts', vim.log.levels.WARN)
    return
  end
  local source_width = vim.api.nvim_win_get_width(M.source_win)

  -- Largura da nova janela: 30% da janela principal
  local test_width = math.floor(source_width * 0.40)
  if test_width < 1 then test_width = 1 end
  if test_width >= source_width then test_width = source_width - 1 end

  if is_floating then
    local float_win = vim.api.nvim_create_buf(false, false)
    local opts = { relative = 'editor', width = test_width, row = 0, col = source_width, height = 10 }
    vim.api.nvim_open_win(float_win, 0, opts)
    vim.cmd('terminal ' .. ('npm run test:watch -- ' .. abs_path))
    return
  end

  vim.cmd('rightbelow ' .. tostring(test_width) .. 'vnew') -- split vertical + janela ativa
  vim.cmd('terminal ' .. ('npm run test -- ' .. abs_path))

  -- Volta pra janela do código quando o processo de teste termina.
  vim.schedule(function() vim.api.nvim_set_current_win(M.source_win) end)
end

-- <leader>tf : split vertical + npm run test -- <arquivo>
vim.keymap.set('n', '<leader>tf', test_file, { desc = '[TF] testar arquivo (.test.ts)' })
-- <leader>tr : float window + npm run test -- run -- <arquivo>
vim.keymap.set('n', '<leader>tr', function() test_file(true) end, { desc = '[TR] testar arquivo float (.test.ts)' })

return M
