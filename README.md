# grain.nvim

Neovim support for [Grain](https://grain-lang.org/)

## Requirements

- [Grain CLI](https://grain-lang.org/) on `PATH` (for LSP)
- `nvim-treesitter/nvim-treesitter` (for `:TSInstall grain` and highlighting)
- `neovim/nvim-lspconfig` (optional. set `enable_lsp = false` if you configure the client yourself)
- [mini.icons](https://github.com/nvim-mini/mini.nvim/blob/main/readmes/mini-icons.md) (`nvim-mini/mini.icons`) for the 🌾 file / filetype icon (merged via `setup()` on load)

## lazy.nvim

```lua
{
  "Kara-Zor-El/grain.nvim",
  dependencies = {
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", lazy = false },
    "neovim/nvim-lspconfig",
    "nvim-mini/mini.icons",
  },
  opts = {
    -- auto_install_parser = true, -- optional: install parser on startup
    -- lsp = { cmd = { "/path/to/grain", "lsp" } },
  },
  config = function(_, opts)
    require("grain").setup(opts)
  end,
}
```

After install, run `:TSInstall grain` once (unless you set `auto_install_parser = true`).

## Options

| Option | Default | Description |
|--------|---------|-------------|
| `filetypes` | `{ extension = { gr = "grain" } }` | Passed to `vim.filetype.add` |
| `treesitter.parser` | `"grain"` | Parser name for nvim-treesitter |
| `treesitter.install_info` | Kara-Zor-El/tree-sitter-grain `main`, `queries` | Custom parser `install_info` |
| `enable_lsp` | `true` | Register and start `lspconfig.grain` |
| `lsp` | `grain lsp`, `root_dir` = buffer’s directory (or cwd), `single_file_support` | Merged into `lspconfig.grain.setup` (no `root_markers` by default) |
| `auto_install_parser` | `false` | Call nvim-treesitter install for `grain` after setup |
