-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require "config.compat"

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- When Neovim runs on a remote host over SSH, use OSC52 so yanks can reach the
-- local system clipboard through the terminal connection.
if (vim.env.SSH_TTY or vim.env.SSH_CONNECTION) and vim.g.clipboard == nil then
  local osc52 = require "vim.ui.clipboard.osc52"
  local clipboard_cache = {
    ["+"] = { lines = {}, regtype = "v" },
    ["*"] = { lines = {}, regtype = "v" },
  }

  local function copy(register)
    local osc52_copy = osc52.copy(register)
    return function(lines, regtype)
      clipboard_cache[register] = {
        lines = vim.deepcopy(lines),
        regtype = regtype,
      }
      osc52_copy(lines, regtype)
    end
  end

  local function paste(register)
    return function()
      local cached = clipboard_cache[register]
      return vim.deepcopy(cached.lines), cached.regtype
    end
  end

  vim.g.clipboard = {
    name = "OSC52 (copy only)",
    copy = {
      ["+"] = copy "+",
      ["*"] = copy "*",
    },
    paste = {
      ["+"] = paste "+",
      ["*"] = paste "*",
    },
  }
end

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.schedule(function()
  vim.opt.clipboard = "unnamedplus"
end)
--
-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

--use editorconfig
vim.g.editorconfig = true
-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

-- set Spelling
vim.opt.spelllang = "en_us"
vim.opt.spell = true

vim.keymap.set("n", "<C-s>", "]s", { desc = "Go to next misspelled text" })
vim.keymap.set("n", "<leader>sp", "[s", { desc = "Go to previous misspelled text" })

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

local function goto_prev_and_center()
  vim.diagnostic.jump { count = -1 }
  vim.cmd "norm! zz"
end
local function goto_next_and_center()
  vim.diagnostic.jump { count = 1 }
  vim.cmd "norm! zz"
end
vim.keymap.set("n", "ü", "ea", { desc = "insert on word end" })

-- Handle File explorer
vim.keymap.set("n", "<leader>ft", "<cmd>Explore<CR>", { desc = "Open file explorer" })
vim.keymap.set("n", "<leader>nf", function()
  local dir = vim.fn.expand "%:p:h"
  if vim.fn.isdirectory(dir) == 0 then
    dir = vim.fn.getcwd()
  end

  local name = vim.fn.input("New file: ", dir .. "/")
  if name == "" then
    return
  end

  vim.cmd("edit " .. vim.fn.fnameescape(name))
end, { desc = "Create new file in current buffer directory" })

-- Diagnostic ]eymaps
vim.keymap.set("n", "tt", goto_prev_and_center, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "TT", goto_next_and_center, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
-- Remap exit to command
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })
-- Mark whole line
vim.keymap.set("n", "vv", "V", { desc = "Select current line" })
-- override line jump to zenter in the middle
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim from " .. lazyrepo)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- "gc" to comment visual regions/lines
  { "numToStr/Comment.nvim", opts = {} },
  {
    "ldelossa/gh.nvim",
    dependencies = {
      {
        "ldelossa/litee.nvim",
        config = function()
          require("litee.lib").setup()
        end,
      },
    },
    config = function()
      require("litee.gh").setup()

      local wk = require "which-key"
      wk.register {
        ["<leader>g"] = { name = "Git" },
        ["<leader>gh"] = { name = "GitHub" },

        -- Commits
        ["<leader>ghc"] = { name = "Commits" },
        ["<leader>ghcc"] = { "<cmd>GHCloseCommit<cr>", "Close Commit" },
        ["<leader>ghce"] = { "<cmd>GHExpandCommit<cr>", "Expand Commit" },
        ["<leader>ghco"] = { "<cmd>GHOpenToCommit<cr>", "Open To Commit" },
        ["<leader>ghcp"] = { "<cmd>GHPopOutCommit<cr>", "Pop Out Commit" },
        ["<leader>ghcz"] = { "<cmd>GHCollapseCommit<cr>", "Collapse Commit" },

        -- Issues
        ["<leader>ghi"] = { name = "Issues" },
        ["<leader>ghip"] = { "<cmd>GHPreviewIssue<cr>", "Preview Issue" },

        -- Litee Panel
        ["<leader>ghl"] = { name = "Litee Panel" },
        ["<leader>ghlt"] = { "<cmd>LTPanel<cr>", "Toggle Panel" },

        -- Pull Requests
        ["<leader>ghp"] = { name = "Pull Request" },
        ["<leader>ghpc"] = { "<cmd>GHClosePR<cr>", "Close PR" },
        ["<leader>ghpd"] = { "<cmd>GHPRDetails<cr>", "PR Details" },
        ["<leader>ghpe"] = { "<cmd>GHExpandPR<cr>", "Expand PR" },
        ["<leader>ghpo"] = { "<cmd>GHOpenPR<cr>", "Open PR" },
        ["<leader>ghpp"] = { "<cmd>GHPopOutPR<cr>", "Pop Out PR" },
        ["<leader>ghpr"] = { "<cmd>GHRefreshPR<cr>", "Refresh PR" },
        ["<leader>ghpt"] = { "<cmd>GHOpenToPR<cr>", "Open To PR" },
        ["<leader>ghpz"] = { "<cmd>GHCollapsePR<cr>", "Collapse PR" },
        ["<leader>ghpn"] = { "<cmd>GHCreatePR<cr>", "New PR" },

        -- Reviews
        ["<leader>ghr"] = { name = "Review" },
        ["<leader>ghrb"] = { "<cmd>GHStartReview<cr>", "Start Review" },
        ["<leader>ghrc"] = { "<cmd>GHCloseReview<cr>", "Close Review" },
        ["<leader>ghrd"] = { "<cmd>GHDeleteReview<cr>", "Delete Review" },
        ["<leader>ghre"] = { "<cmd>GHExpandReview<cr>", "Expand Review" },
        ["<leader>ghrs"] = { "<cmd>GHSubmitReview<cr>", "Submit Review" },
        ["<leader>ghrz"] = { "<cmd>GHCollapseReview<cr>", "Collapse Review" },

        -- Threads
        ["<leader>ght"] = { name = "Threads" },
        ["<leader>ghtc"] = { "<cmd>GHCreateThread<cr>", "Create Thread" },
        ["<leader>ghtn"] = { "<cmd>GHNextThread<cr>", "Next Thread" },
        ["<leader>ghtt"] = { "<cmd>GHToggleThread<cr>", "Toggle Thread" },
      }
    end,
  },

  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required
      "sindrets/diffview.nvim", -- Optional - Diff integration
      "nvim-telescope/telescope.nvim", -- Optional - Telescope integration
    },
    cmd = "Neogit", -- Lazy-load on :Neogit
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "Open Neogit" },
    },
    config = function()
      local neogit = require "neogit"
      neogit.setup {
        disable_hint = true,
        integrations = {
          diffview = true,
          telescope = true,
        },
      }
    end,
  },

  -- Here is a more advanced example where we pass configuration
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    config = function() -- This is the function that runs, AFTER loading
      require("which-key").setup()

      -- Document existing key chains
      require("which-key").register {
        ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
        ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
        ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
        ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
        ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
        ["<leader>t"] = { name = "[T]oggle", _ = "which_key_ignore" },
        ["<leader>h"] = { name = "Git [H]unk", _ = "which_key_ignore" },
      }
      -- visual mode
      require("which-key").register({
        ["<leader>h"] = { "Git [H]unk" },
      }, { mode = "v" })
    end,
  },

  -- NOTE: Plugins can specify dependencies.
  --
  -- The dependencies are proper plugin specifications as well - anything
  -- you do for a plugin at the top level, you can do for a dependency.
  --
  -- Use the `dependencies` key to specify the dependencies of a particular plugin

  require "config.plugins.telescope",
  require "config.plugins.lsp",
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
      },

      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 5000,
        lsp_fallback = true,
      },
    },
  },

  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
    },
    config = function()
      -- See `:help cmp`
      local cmp = require "cmp"
      local luasnip = require "luasnip"
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },
        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          --  ["<C-n>"] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          --- ["<C-m>"] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ["<C-y>"] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ["<CR>"] = cmp.mapping.confirm { select = true },
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ["<C-Space>"] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ["<C-l>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<C-h>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "path" },
        },
      }
    end,
  },

  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    "folke/tokyonight.nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme "tokyonight-night"
      vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#51B3EC", bold = false })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#edf516", bold = true })
      vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#51B3EC", bold = false })
      vim.api.nvim_set_hl(0, "Comment", { fg = "#009129", bold = false })
      vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { fg = "#8c6464", bold = false })
      vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { fg = "#8c6464", bold = false })
      -- You can configure highlights by doing something like:
      vim.cmd.hi "Comment gui=none"
    end,
  },
  -- Highlight todo, notes, etc in comments
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require "mini.statusline"
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
  require "config.plugins.treesitter",

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.indent_line',
  require "kickstart.plugins.lint",
  -- require 'kickstart.plugins.autopairs',
  -- require 'kickstart.plugins.neo-tree',
  require "kickstart.plugins.gitsigns", -- adds gitsigns recommend keymaps
  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`

  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  -- require("gitsigns").setup {
  --   current_line_blame = true,
  -- },
  --{ import = "custom.plugins" },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
