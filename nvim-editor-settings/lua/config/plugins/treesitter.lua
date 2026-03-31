return { -- Highlight, edit, and navigate code
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "python", "bash", "c", "html", "lua", "luadoc", "markdown", "vim", "vimdoc" },
    auto_install = false,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { "ruby" },
    },
    indent = { enable = true, disable = { "ruby" } },
  },
  config = function(_, opts)
    local parser_dir = vim.fs.joinpath(vim.fn.stdpath "cache", "treesitter")
    vim.fn.mkdir(parser_dir, "p")
    vim.opt.runtimepath:append(parser_dir)
    opts.parser_install_dir = parser_dir
    if #vim.api.nvim_list_uis() == 0 then
      opts.ensure_installed = {}
    end

    require("nvim-treesitter.install").prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup(opts)
  end,
}
