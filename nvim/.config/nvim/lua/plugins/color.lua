return {
  "alligator/accent.vim",
  config = function()
    vim.g.accent_colour = "orange"
    vim.cmd([[colorscheme accent]])
  end
}
