local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
  vim.notify "JDTLS not found, install with `:MasonInstall jdtls`"
  return
end

-- Setting root dir:
local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
local root_dir = jdtls.setup.find_root(root_markers)
if root_dir == "" then
  return
end

-- Data directory - change it to your liking
local HOME = os.getenv('HOME')
local workspace_folder = HOME .. "/.workspace" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

-- Installation location of jdtls by nvim-lsp-installer
local JDTLS_LOCATION = vim.fn.stdpath "data" .. "/mason/packages/jdtls"

-- Only for Linux and Mac
local SYSTEM = "win"
if vim.fn.has "linux" == 1 then
  SYSTEM = "linux"
end

-- Adding  capabilities:
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Setting the config file for jdtls:
local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '--add-modules=ALL-SYSTEM',
    '--add-opens',
    'java.base/java.util=ALL-UNNAMED',
    '--add-opens',
    'java.base/java.lang=ALL-UNNAMED',

    -- Path to the eclipse.jdt.ls plugins folder and jar:
    '-jar',
    vim.fn.glob(JDTLS_LOCATION .. '/plugins/org.eclipse.equinox.launcher_*.jar'),

    -- Path to the current system folder for the language server:
    '-configuration',
    JDTLS_LOCATION .. '/config_' .. SYSTEM,

    -- Setting the 'data' folder to be the workspace_dir variable:
    '-data',
    workspace_folder,
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = root_dir,
  capabilities = capabilities,
  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      project = {
        referencedLibraries = {
        },
      },
      eclipse = {
        downloadSources = true,
      },
      maven = {
        downloadSources = true,
      },
      implementationsCodeLens = {
        enabled = true,
      },
      referenceCodeLens = {
        enabled = true,
      },
      references = {
        enabled = true,
      },
      format = {
        enabled = true,
        settings = {
          url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
          profile = "GoogleStyle",
        },
      },
      classPath = {
      },
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' }, -- Use fernflower to decompile library code
      -- Specify any completion options
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*", "sun.*",
        },
      },
      -- Specify any options for organizing imports
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
      -- How code generation should act
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      },
      -- If you are developing in projects with different Java versions, you need
      -- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- And search for `interface RuntimeOption`
      -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          {
            name = "JavaSE-17",
            path = 'C:/Program Files/Eclipse Adoptium/jdk-17.0.8.101-hotspot/',
            default = true,
          },
          {
            name = "JavaSE-1.8",
            path = 'C:/Program Files/Java/jre-1.8'
          },
        }
      }
    }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {
      vim.fn.glob(
        'C:/Users/renan/Documents/git/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar'),
    }
  },
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
jdtls.start_or_attach(config)

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
vim.keymap.set('n', '<leader>oi', '<cmd>lua require\'jdtls\'.organize_imports()<CR>', { desc = '[O]rganize [I]mports' })
vim.keymap.set('n', '<leader>rj', function()
  local paths = {}
  table.insert(paths, vim.fn.getcwd() .. '/bin');
  local classpathFilename = vim.fn.getcwd() .. '/.classpath';
  local file = io.open(classpathFilename, "r")
  if file then
    local content = file:read("*a")
    file:close()
    for path in string.gmatch(content, 'path="([^"]*.jar)"') do
      table.insert(paths, vim.fn.getcwd() .. '/' .. path)
    end
  end
  local classpath = table.concat(paths, ";")
  for path in ipairs(paths) do
    print(path)
  end
  vim.cmd('!java -cp "' .. classpath .. '" %')
end, { desc = '[R]un [J]ava file' })
