-- === Requires / shortcuts ===
local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require 'luasnip.util.events'
local ai = require 'luasnip.nodes.absolute_indexer'
local extras = require 'luasnip.extras'
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local types = require 'luasnip.util.types'
local parse = require('luasnip.util.parser').parse_snippet
local ms = ls.multi_snippet
local k = require('luasnip.nodes.key_indexer').new_key

-- Mapeia <C-M> (Enter) para pular para o próximo campo
vim.keymap.set({ "i", "s" }, "<C-M>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  else
    -- Se não tiver nada para pular, age como um Enter normal
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
  end
end, { silent = true })
-- Mapeia <C-N> para pular para o próximo campo
vim.keymap.set({ "i", "s" }, "<C-N>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

-- Mapeia <C-P> para voltar pro campo anterior
vim.keymap.set({ "i", "s" }, "<C-P>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

-- ===================================================================
-- Tree-sitter
-- ===================================================================
local ts_ok, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')

-- DEBUG: controlar notificações para investigar comportamentos
local DEBUG_TS_SNIPPET = true
local function debug(msg)
  if DEBUG_TS_SNIPPET then
    -- vim.schedule para evitar chamadas síncronas durante eventos sensíveis
    vim.schedule(function() vim.notify("[luasnip-ts] " .. tostring(msg), vim.log.levels.INFO) end)
  end
end

-- ===================================================================
-- safe_get_node_text
-- -> pega o texto do node de forma segura, usando a API recomendada
--    vim.treesitter.get_node_text(node, bufnr)
-- Por que trocar? a API antiga vim.treesitter.query.get_node_text foi
-- marcada como deprecada — portanto usamos a função de runtime recomendada.
-- Observação: usamos pcall para proteger contra erros ocasionais do parser.
-- ===================================================================
local function safe_get_node_text(node)
  -- se não tiver node, nada a fazer
  if not node then return nil end

  -- a API principal que queremos usar agora é vim.treesitter.get_node_text
  -- (mais estável / recomendada nas versões recentes do Neovim).
  -- Usamos pcall porque, se o parser tiver algum problema momentâneo,
  -- não queremos travar o Neovim. (Veja issues/ads sobre deprecações).
  local ok, txt = pcall(function()
    -- vim.treesitter.get_node_text aceita (node, bufnr)
    return vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf())
  end)

  if not ok then
    debug("vim.treesitter.get_node_text falhou")
    return nil
  end

  -- alguns helpers retornam tabela de linhas; garantimos string final
  if type(txt) == "table" then
    return table.concat(txt, "\n")
  end
  return txt
end

-- ===================================================================
-- get_identifier_at_cursor
-- objetivo: obter o identificador/variável sob o cursor usando Tree-sitter;
-- fallback: vim.fn.expand('<cword>') (palavra sob o cursor).
--
-- detalhe importante:
-- - ts_utils.get_node_at_cursor() (do nvim-treesitter) retorna um TSNode
--   que permite subir a árvore com :parent(), chamar :type(), etc.
-- - A API builtin vim.treesitter tem funções auxiliares também, mas alguns
--   retornos diferem; por isso mantemos ts_utils para pegar o TSNode.
-- ===================================================================
local function get_identifier_at_cursor()
  -- fallback simples (palavra sob o cursor) caso TS não funcione
  local fallback = vim.fn.expand('<cword>') or ''

  if not ts_ok or not ts_utils then
    debug("nvim-treesitter.ts_utils não disponível; usando fallback: " .. fallback)
    return fallback
  end

  -- obtém o node sob o cursor (ts_utils.get_node_at_cursor retorna um TSNode)
  local ok, node = pcall(ts_utils.get_node_at_cursor)
  if not ok or not node then
    debug("ts_utils.get_node_at_cursor falhou ou retornou nil; fallback: " .. fallback)
    return fallback
  end

  -- lista de tipos (nomes de nodes) que costumam conter identificadores
  -- esses nomes dependem do parser/language; ajuste conforme precisar.
  local kinds = {
    identifier = true,
    name = true,
    variable_name = true,
    property_identifier = true,
    field_identifier = true,
    identifier_expression = true,
  }

  -- sobe na árvore até um limite (evita loops infinitos caso algo estranho aconteça)
  local cur = node
  local max_up = 10
  for tree_node = 1, max_up do
    if not cur then break end

    -- chamar cur:type() pode falhar raramente -> usamos pcall
    local ok_type, tname = pcall(function() return cur:type() end)
    local ntype = nil
    if ok_type then ntype = tname end

    debug(("level %d type=%s"):format(tree_node, tostring(ntype)))

    -- se o tipo do node é um dos que reconhecemos como identificador, extrai texto
    if ntype and kinds[ntype] then
      local txt = safe_get_node_text(cur)
      if txt and txt ~= "" then
        debug("encontrei identificador via TS: " .. txt .. " tipo: " .. ntype)
        return txt
      end
    end

    -- sobe para o parent e continua a busca
    cur = cur:parent()
  end

  -- se nada for encontrado pelo TS, usamos o fallback
  debug("não encontrou via TS, usando fallback: " .. fallback)
  return fallback
end

-- ===================================================================
-- UTIL: pegar seleção visual
-- -> usa marcas '< e '> para determinar posição da seleção visual
-- -> tenta usar nvim_buf_get_text (mais robusto) e faz fallback para getline
-- retorna: texto, start_row, end_row (rows 1-indexed)
-- ===================================================================
local function get_visual_selection_text()
  -- posição das marks: {bufnr, lnum, col, off}
  local s_pos = vim.fn.getpos("'<")
  local e_pos = vim.fn.getpos("'>")
  local bufnr = vim.api.nvim_get_current_buf()
  local sr, sc = s_pos[2], s_pos[3]
  local er, ec = e_pos[2], e_pos[3]

  -- pcall para evitar possíveis erros em buffers/posições estranhas
  local ok, lines = pcall(vim.api.nvim_buf_get_text, bufnr, sr-1, sc-1, er-1, ec, {})
  if not ok then
    -- fallback simples usando getline
    local raw = vim.api.nvim_buf_get_lines(bufnr, sr-1, er, false)
    if not raw then return nil, sr, er end
    return table.concat(raw, "\n"), sr, er
  end
  return table.concat(lines, "\n"), sr, er
end

-- ===================================================================
-- UTIL: inserir linhas após uma linha específica (row é 1-indexed)
-- -> usa nvim_buf_set_lines com a posição correta para inserir as linhas
-- ===================================================================
local function insert_line_after(row, text)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.split(text, '\n', true)
  -- inserir em índice `row` (inserir depois de `row` 1-indexed)
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, lines)
end

-- ===================================================================
-- ACTIONS: funções que inserem console.log(...)
-- ===================================================================

-- Modo normal: pega identificador sob cursor (Tree-sitter) e insere a linha abaixo
local function console_log_for_cursor()
  local name = get_identifier_at_cursor() or ''
  if name == '' then
    -- notifica o usuário e aborta caso não encontre nada
    vim.notify("Nenhuma variável encontrada sob o cursor.", vim.log.levels.WARN)
    return
  end
  -- pega a linha atual do cursor (1-indexed)
  local cur_row = vim.api.nvim_win_get_cursor(0)[1]
  local line_to_insert = string.format("console.log(%s);", name)
  insert_line_after(cur_row, line_to_insert)
  debug("inserido: " .. line_to_insert .. " after row " .. tostring(cur_row))
end

-- Modo visual: pega seleção e insere console.log(<seleção>); depois da seleção
local function console_log_for_visual()
  local sel_text, sr, er = get_visual_selection_text()
  if not sel_text or sel_text == "" then
    vim.notify("Seleção vazia.", vim.log.levels.WARN)
    return
  end
  -- trim nas bordas por segurança
  sel_text = sel_text:gsub("^%s+", ""):gsub("%s+$", "")
  local line_to_insert = string.format("console.log(%s);", sel_text)
  insert_line_after(er, line_to_insert)
  debug("inserido (visual): " .. line_to_insert .. " after row " .. tostring(er))
  -- limpa seleção (volta para normal)
  pcall(vim.api.nvim_feedkeys, vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'n', true)
end

-- ===================================================================
-- Keymaps: mapear <leader>l para ambas as ações (normal e visual)
-- ===================================================================
local function opts(name) return { desc = name, noremap = true, silent = true } end
vim.keymap.set('n', '<leader>l', function() console_log_for_cursor() end, opts("[L]og variable"))
vim.keymap.set('v', '<leader>l', function() console_log_for_visual() end, opts("[L]og visual select"))
vim.keymap.set('n', '<leader>ld', function() get_identifier_at_cursor() end, opts("[D]ebug toggle"))

-- ===================================================================
-- LuaSnip setup (mantive sua configuração)
-- ===================================================================
ls.setup {
  keep_roots = true,
  link_roots = true,
  link_children = true,
  update_events = 'TextChanged,TextChangedI',
  delete_check_events = 'TextChanged',
  ext_opts = {
    [types.choiceNode] = {
      active = {
        virt_text = { { 'choiceNode', 'Comment' } },
      },
    },
  },
  enable_autosnippets = true,
  cut_selection_keys = '<Tab>',
  ft_func = function()
    return vim.split(vim.bo.filetype, '.', true)
  end,
}

-- ===================================================================
-- Snippets (mantive e corrigi a parte do snippet hover/console)
-- ===================================================================
local quickJavaDebugSnippet = s('dlog', {
  t 'System.out.println("DEBUG: ',
  i(1, 'variable'),
  t ': " + ',
  rep(1),
  t ');',
}, { name = '[D]ebug Log'})

local quickJSDebugSnippet = s('dlog', {
  t 'console.log("DEBUG: ',
  i(1, 'variable'),
  t '", ',
  rep(1),
  t ');',
}, { name = '[D]ebug Log'})

local timestampDebugSnippet = s('tlog', {
  t 'console.log(`DEBUG [${new Date().toLocaleTimeString()}]: ',
  i(2, 'message'),
  t '`, ',
  i(1, 'variable'),
  t ');',
})

local jsonDebugSnippet = s('jlog', {
  t 'console.log("DEBUG: ',
  i(1, 'object'),
  t '", JSON.stringify(',
  rep(1),
  t ', null, 2));',
})

-- Snippet hover: usa get_identifier_at_cursor dentro do dynamic node
-- (o snippet em si não faz inserção no buffer; apenas insere o texto no ponto do snippet)
local console_log_snippet = s(
  'cl',
  fmt('console.log({});', {
    d(1, function(_, _snip)
      local name = get_identifier_at_cursor()
      if name ~= nil and name ~= '' then
        -- se encontramos algo via TS, retornamos um texto estático (t)
        -- se preferir que seja editável após expansão, troque t(name) por i(1, name)
        return sn(nil, t(name))
      else
        -- fallback: insere um insert_node para o usuário digitar
        return sn(nil, i(1, 'variable'))
      end
    end, {}),
  })
)

-- agrupa os snippets JS/TS e registra
local all_javascript_snippets = {
  quickJSDebugSnippet,
  timestampDebugSnippet,
  jsonDebugSnippet,
  console_log_snippet, -- corrigido: incluí o snippet com nome correto
}

ls.add_snippets('javascript', all_javascript_snippets)
ls.add_snippets('typescript', all_javascript_snippets)
ls.add_snippets('typescriptreact', all_javascript_snippets)
ls.add_snippets('javascriptreact', all_javascript_snippets)

ls.add_snippets('java', quickJavaDebugSnippet)

-- opcional: exportar utilitários para debugging manual
return {
  get_identifier_at_cursor = get_identifier_at_cursor,
  console_log_for_cursor = console_log_for_cursor,
  console_log_for_visual = console_log_for_visual,
}
