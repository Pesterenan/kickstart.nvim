-- Atalhos para testar arquivos '.test.*' / '.spec.*' com vitest.
--
-- <leader>tf : split vertical reutilizável + single run (`npx vitest run <arquivo...>`)
-- <leader>tr : float toggle + watch (`npx vitest <arquivo...> --watch`)
-- <leader>tq : mata os jobs e fecha as janelas de teste
--
-- Funciona no .test.* / .spec.* OU no arquivo fonte: de `penTool.ts`
-- resolve os irmãos `penTool.test.ts`, `penTool.bezier.test.ts`, ...; fora disso avisa e não abre.
-- Usa `npx vitest` direto; se não houver vitest local, cai para
-- `npm run test:unit` (tf) / `npm run test:watch` (tr).
-- `--config` só é passado quando o config está fora da raiz do projeto.

local M = {}

M.split = { buf = nil, win = nil, job = nil }
M.float = { buf = nil, win = nil, job = nil, files = nil }
M.source_win = nil

local CONFIG_NAMES = {
  'vitest.config.ts',
  'vitest.config.mts',
  'vitest.config.js',
  'vitest.config.mjs',
  'vite.config.ts',
  'vite.config.mts',
  'vite.config.js',
  'vite.config.mjs',
}

local ROOT_MARKERS = {
  'package.json',
  'vitest.config.ts',
  'vitest.config.mts',
  'vitest.config.js',
  'vitest.config.mjs',
  'vite.config.ts',
  'vite.config.js',
  'pnpm-workspace.yaml',
}

local function is_valid_buf(buf) return buf ~= nil and vim.api.nvim_buf_is_valid(buf) end

local function is_valid_win(win) return win ~= nil and vim.api.nvim_win_is_valid(win) end

local function is_test_filename(name) return name:match '%.test%.%w+$' ~= nil or name:match '%.spec%.%w+$' ~= nil end

local function files_equal(a, b)
  if a == nil or b == nil or #a ~= #b then return false end
  for i = 1, #a do
    if a[i] ~= b[i] then return false end
  end
  return true
end

-- Rótulo curto para título/notify: 1 arquivo mostra o nome,
-- N arquivos mostra `stem (N arquivos)`.
local function files_label(files, stem)
  if #files == 1 then return vim.fn.fnamemodify(files[1], ':t') end
  return stem .. ' (' .. #files .. ' arquivos)'
end

-- Resolve os alvos de teste para o buffer atual:
-- - buffer .test.*/.spec.* -> só ele;
-- - fonte `penTool.ts` -> irmãos `penTool.test.ts`, `penTool.bezier.test.ts`, ...
--   (mesmo diretório, prefixo `stem.`). Retorna lista ordenada ou nil.
local function resolve_test_files()
  local abs = vim.fn.expand '%:p'
  if abs == nil or abs == '' then
    vim.notify('[Testing] buffer sem arquivo, abra um .ts ou .test.ts', vim.log.levels.WARN)
    return nil
  end
  local name = vim.fn.fnamemodify(abs, ':t')
  if is_test_filename(name) then return { abs } end
  local stem = name:match '^(.+)%.[^.]+$' or name
  local dir = vim.fn.fnamemodify(abs, ':p:h')
  local escaped = stem:gsub('([^%w])', '%%%1')
  local prefix_pat = '^' .. escaped .. '%.'
  local ok, iter = pcall(vim.fs.dir, dir)
  if not ok or iter == nil then
    vim.notify('[Testing] não consegui listar ' .. dir, vim.log.levels.ERROR)
    return nil
  end
  local matches = {}
  for entry, ftype in iter do
    if ftype == 'file' and entry:match(prefix_pat) ~= nil and is_test_filename(entry) then table.insert(matches, vim.fs.joinpath(dir, entry)) end
  end
  table.sort(matches)
  if #matches == 0 then
    vim.notify('[Testing] nenhum teste para ' .. stem .. ' neste diretório', vim.log.levels.WARN)
    return nil
  end
  return matches, stem
end

local function remember_source_win()
  local win = vim.api.nvim_get_current_win()
  if win ~= M.float.win and win ~= M.split.win then M.source_win = win end
end

local function get_root(abs_path)
  local start = vim.fn.fnamemodify(abs_path, ':p:h')
  local ok, root = pcall(vim.fs.root, start, ROOT_MARKERS)
  if ok and root ~= nil then return root end
  return vim.fn.getcwd()
end

-- Vitest auto-descobre o config a partir do root. Só retorna um path
-- explícito quando o config está fora do root (ex. monorepo).
local function find_explicit_config(abs_path, root)
  local start = vim.fn.fnamemodify(abs_path, ':p:h')
  local ok, found = pcall(vim.fs.find, CONFIG_NAMES, { path = start, upward = true, type = 'file', limit = 1 })
  if not ok or found == nil or #found == 0 then return nil end
  local cfg = found[1]
  local cfg_dir = vim.fn.fnamemodify(cfg, ':p:h')
  local norm_root = vim.fn.fnamemodify(root, ':p')
  local norm_cfg_dir = vim.fn.fnamemodify(cfg_dir, ':p')
  if norm_cfg_dir == norm_root then return nil end
  return cfg
end

local function has_local_vitest(root)
  local base = vim.fs.joinpath(root, 'node_modules', '.bin', 'vitest')
  if vim.fn.filereadable(base) == 1 then return true end
  if vim.fn.filereadable(base .. '.cmd') == 1 then return true end
  return false
end

local function read_package_scripts(root)
  local pkg = vim.fs.joinpath(root, 'package.json')
  if vim.fn.filereadable(pkg) == 0 then return {} end
  local ok_lines, lines = pcall(vim.fn.readfile, pkg)
  if not ok_lines then return {} end
  local ok_json, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok_json or type(data) ~= 'table' then return {} end
  if type(data.scripts) == 'table' then return data.scripts end
  return {}
end

--- Monta o comando (lista, sem shell) + cwd.
--- @param abs_paths table lista de arquivos de teste
--- @param mode 'single'|'watch'
--- @return table|nil cmd, string|nil cwd
local function build_cmd(abs_paths, mode, root)
  local cfg = find_explicit_config(abs_paths[1], root)
  if has_local_vitest(root) then
    local cmd = { 'npx', 'vitest' }
    if cfg ~= nil then vim.list_extend(cmd, { '--config', cfg }) end
    if mode == 'single' then
      vim.list_extend(cmd, { 'run' })
      vim.list_extend(cmd, abs_paths)
      vim.list_extend(cmd, { '--reporter=default' })
    else
      vim.list_extend(cmd, abs_paths)
      vim.list_extend(cmd, { '--watch', '--reporter=default' })
    end
    return cmd, root
  end

  -- Fallback para scripts npm do projeto.
  local scripts = read_package_scripts(root)
  if mode == 'watch' then
    if scripts['test:watch'] ~= nil then
      vim.notify('[Testing] sem vitest local, usando npm run test:watch', vim.log.levels.WARN)
      local cmd = { 'npm', 'run', 'test:watch', '--' }
      vim.list_extend(cmd, abs_paths)
      return cmd, root
    end
    if scripts['test'] ~= nil then
      vim.notify('[Testing] sem vitest local, usando npm run test', vim.log.levels.WARN)
      local cmd = { 'npm', 'run', 'test', '--' }
      vim.list_extend(cmd, abs_paths)
      return cmd, root
    end
  else
    if scripts['test:unit'] ~= nil then
      vim.notify('[Testing] sem vitest local, usando npm run test:unit', vim.log.levels.WARN)
      local cmd = { 'npm', 'run', 'test:unit', '--' }
      vim.list_extend(cmd, abs_paths)
      return cmd, root
    end
    if scripts['test'] ~= nil then
      vim.notify('[Testing] sem vitest local, usando npm run test', vim.log.levels.WARN)
      local cmd = { 'npm', 'run', 'test', '--' }
      vim.list_extend(cmd, abs_paths)
      return cmd, root
    end
  end
  vim.notify('[Testing] vitest não encontrado e sem script npm (test/test:unit/test:watch)', vim.log.levels.ERROR)
  return nil, nil
end

local function scroll_to_bottom(win)
  if not is_valid_win(win) then return end
  vim.schedule(function()
    if not is_valid_win(win) then return end
    pcall(vim.api.nvim_win_call, win, function() pcall(vim.cmd, 'normal! G') end)
  end)
end

local function stop_job(target)
  if target.job ~= nil then
    pcall(vim.fn.jobstop, target.job)
    target.job = nil
  end
end

local function on_output(target)
  return function()
    if is_valid_win(target.win) then scroll_to_bottom(target.win) end
  end
end

local function fresh_term_buf()
  local buf = vim.api.nvim_create_buf(false, true) -- scratch, unlisted
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].scrollback = 10000
  return buf
end

--- Roda `cmd` no buffer do alvo, reusando o buf e matando o job anterior.
local function spawn(target, cmd, cwd, on_exit)
  stop_job(target)
  if not is_valid_buf(target.buf) then target.buf = fresh_term_buf() end
  local buf = target.buf
  vim.api.nvim_buf_call(
    buf,
    function()
      target.job = vim.fn.termopen(cmd, {
        cwd = cwd,
        on_stdout = on_output(target),
        on_stderr = on_output(target),
        on_exit = on_exit,
      })
    end
  )
  if target.job == nil or target.job <= 0 then
    vim.notify('[Testing] falha ao iniciar: ' .. table.concat(cmd, ' '), vim.log.levels.ERROR)
    return false
  end
  return true
end

local function ensure_split_win()
  if is_valid_win(M.split.win) then return M.split.win end
  local width = math.floor(vim.o.columns * 0.40)
  if width < 30 then width = 30 end
  vim.cmd 'rightbelow vnew'
  local win = vim.api.nvim_get_current_win()
  M.split.win = win
  if is_valid_buf(M.split.buf) then
    vim.api.nvim_win_set_buf(win, M.split.buf)
  else
    M.split.buf = vim.api.nvim_win_get_buf(win)
    vim.bo[M.split.buf].bufhidden = 'hide'
    vim.bo[M.split.buf].scrollback = 10000
  end
  pcall(vim.api.nvim_win_set_width, win, width)
  return win
end

local function ensure_float_win(title)
  if is_valid_win(M.float.win) then return M.float.win end
  local width = math.floor(vim.o.columns * 0.55)
  local height = math.floor(vim.o.lines * 0.60)
  if width < 40 then width = 40 end
  if height < 10 then height = 10 end
  local row = math.floor((vim.o.lines - height) / 2) - 1
  local col = math.floor((vim.o.columns - width) / 2)
  if row < 0 then row = 0 end
  if col < 0 then col = 0 end
  if not is_valid_buf(M.float.buf) then M.float.buf = fresh_term_buf() end
  local win = vim.api.nvim_open_win(M.float.buf, false, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = title,
    title_pos = 'center',
  })
  M.float.win = win
  return win
end

local function go_back_to_source()
  vim.schedule(function()
    if M.source_win ~= nil and vim.api.nvim_win_is_valid(M.source_win) then pcall(vim.api.nvim_set_current_win, M.source_win) end
  end)
end

-- <leader>tf : single run no split reutilizável.
local function run_single()
  local files, stem = resolve_test_files()
  if not files then return end
  remember_source_win()
  local root = get_root(files[1])
  local cmd, cwd = build_cmd(files, 'single', root)
  if cmd == nil then return end
  local short = files_label(files, stem)
  ensure_split_win()
  local ok = spawn(M.split, cmd, cwd, function(_, code)
    scroll_to_bottom(M.split.win)
    vim.schedule(function()
      if code == 0 then
        vim.notify('[Testing] ' .. short .. ': passou', vim.log.levels.INFO)
      else
        vim.notify('[Testing] ' .. short .. ': falhou (exit ' .. code .. ')', vim.log.levels.ERROR)
      end
    end)
  end)
  if ok then
    if #files > 1 then vim.notify('[Testing] rodando ' .. #files .. ' arquivos: ' .. table.concat(files, ', '), vim.log.levels.INFO) end
    scroll_to_bottom(M.split.win)
    go_back_to_source()
  end
end

-- <leader>tr : toggle do watch no float. Esconder mantém o job vivo.
local function toggle_watch()
  local files, stem = resolve_test_files()
  if not files then return end
  remember_source_win()
  -- Float visível -> esconde e mantém rodando em background.
  if is_valid_win(M.float.win) then
    vim.api.nvim_win_hide(M.float.win)
    M.float.win = nil
    vim.notify('[Testing] watch em background (tr mostra, tq mata)', vim.log.levels.INFO)
    return
  end
  -- Float escondido com os mesmos arquivos e job vivo -> só mostra de novo.
  if is_valid_buf(M.float.buf) and M.float.job ~= nil and files_equal(M.float.files, files) then
    ensure_float_win(' vitest watch: ' .. files_label(files, stem) .. ' ')
    scroll_to_bottom(M.float.win)
    return
  end
  local root = get_root(files[1])
  local cmd, cwd = build_cmd(files, 'watch', root)
  if cmd == nil then return end
  local short = files_label(files, stem)
  ensure_float_win(' vitest watch: ' .. short .. ' ')
  local ok = spawn(M.float, cmd, cwd, function(_, code)
    vim.schedule(function() vim.notify('[Testing] watch saiu (exit ' .. code .. ')', vim.log.levels.WARN) end)
  end)
  if ok then
    M.float.files = files
    if #files > 1 then vim.notify('[Testing] observando ' .. #files .. ' arquivos: ' .. table.concat(files, ', '), vim.log.levels.INFO) end
    scroll_to_bottom(M.float.win)
  end
end

local function close_all()
  for _, target in ipairs { M.split, M.float } do
    stop_job(target)
    if is_valid_win(target.win) then pcall(vim.api.nvim_win_close, target.win, true) end
    target.win = nil
    if is_valid_buf(target.buf) then pcall(vim.api.nvim_buf_delete, target.buf, { force = true }) end
    target.buf = nil
  end
  M.float.files = nil
  go_back_to_source()
end

vim.keymap.set('n', '<leader>tf', run_single, { desc = '[TF] vitest run (fonte ou .test.*)' })
vim.keymap.set('n', '<leader>tr', toggle_watch, { desc = '[TR] vitest watch (fonte ou .test.*, toggle)' })
vim.keymap.set('n', '<leader>tq', close_all, { desc = '[TQ] fechar testes e matar jobs' })

return M
