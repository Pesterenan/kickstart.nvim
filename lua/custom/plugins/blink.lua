require('blink.cmp').setup {
  keymap = {
    preset = 'default',
    ['<c-m>'] = { 'select_and_accept', 'fallback' },
    ['<c-space>'] = { 'show', 'fallback' },
  },

  completion = {
    list = {
      selection = {
        preselect = true,
        auto_insert = true,
      },
    },
    keyword = {
      range = 'prefix',
    },
    -- Show documentation window automatically to see full import paths
    documentation = { auto_show = true, auto_show_delay_ms = 500 },
    ghost_text = { enabled = true },
    menu = {
      auto_show = true,
      auto_show_delay_ms = 100,
      draw = {
        columns = {
          { 'kind_icon' },
          { 'label', 'label_description', gap = 1 },
          { 'source_name' },
        },
      },
    },
    accept = {
      create_undo_point = true,
    },
    trigger = {
      show_in_snippet = true,
      show_on_trigger_character = true,
      show_on_accept_on_trigger_character = true,
      show_on_blocked_trigger_characters = { '\n', '\t' },
      show_on_keyword = true,
    },
  },
}
