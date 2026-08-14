-- blink.cmp overrides on top of the kickstart base config in `init.lua`
-- (kept separate so a rebase of the base config can't wipe these tweaks).

require('blink.cmp.config').merge_with {
  completion = {
    menu = {
      draw = {
        components = {
          -- Show the import source (module path) on the right side of the menu.
          --
          -- `ts_ls` (typescript-language-server) does not send
          -- `labelDetails.description`; it puts the module path in the
          -- top-level `detail` field of the completion item:
          --   - before resolve: "./modA"
          --   - after resolve:  "Auto import from './modA'\nfunction getConfig(): string"
          -- blink.cmp only renders `labelDetails`, so two imports with the same
          -- name looked identical. This component surfaces that module path.
          label_description = {
            width = { max = 40 },
            text = function(ctx)
              -- Most LSPs send the import source through `labelDetails.description`
              if ctx.label_description ~= '' then return ctx.label_description end

              if ctx.item.client_name ~= 'ts_ls' then return '' end
              local detail = ctx.item.detail
              if not detail or detail == '' then return '' end

              local source = detail:match "Auto import from '([^']+)'"
              if source then return source end

              -- Before resolve, only auto-import entries carry a `detail`, and
              -- it is the bare module path. Hide resolved signatures
              -- (they contain spaces/parentheses).
              if not detail:find '[%s%(]' then return detail end
              return ''
            end,
            highlight = 'BlinkCmpLabelDescription',
          },
        },
      },
    },
  },
}
