local M = {}

local function default_grain_root_dir(fname, _)
  if fname == nil or fname == "" then
    return vim.fn.getcwd()
  end
  return vim.fn.fnamemodify(fname, ":p:h")
end

local defaults = {
  filetypes = {
    extension = { gr = "grain" },
  },
  treesitter = {
    parser = "grain",
    tier = 1,
    install_info = {
      url = "https://github.com/Kara-Zor-El/tree-sitter-grain",
      branch = "main",
      queries = "queries",
    },
  },
  enable_lsp = true,
  lsp = {
    cmd = { "grain", "lsp" },
    filetypes = { "grain" },
    root_dir = default_grain_root_dir,
    single_file_support = true,
  },
  auto_install_parser = false,
}

local augroup = "grain.nvim"

local grain_icon = { glyph = "🌾", hl = "MiniIconsYellow" }

local function apply_mini_icons()
  local ok, mini_icons = pcall(require, "mini.icons")
  if not ok then
    return
  end
  mini_icons.setup({
    extension = { gr = grain_icon },
    filetype = { grain = grain_icon },
  })
end

local function register_treesitter_parser(treesitter)
  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok or not parsers then
    return
  end
  local parser_name = treesitter.parser
  local entry = {
    install_info = vim.deepcopy(treesitter.install_info),
  }
  if treesitter.tier ~= nil then
    entry.tier = treesitter.tier
  end
  parsers[parser_name] = entry
end

local function ensure_tsupdate_autocmd(treesitter)
  vim.api.nvim_create_augroup(augroup, { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "TSUpdate",
    callback = function()
      register_treesitter_parser(treesitter)
    end,
  })
  register_treesitter_parser(treesitter)
end

local function try_install_parser(parser_name)
  local ok, ts = pcall(require, "nvim-treesitter")
  if ok and type(ts.install) == "function" then
    pcall(ts.install, { parser_name })
    return
  end
  pcall(vim.cmd, "TSInstall " .. parser_name)
end

local function setup_lsp(lsp_opts)
  local ok_configs, configs = pcall(require, "lspconfig.configs")
  local ok_lsp, lspconfig = pcall(require, "lspconfig")
  if not (ok_configs and ok_lsp and configs and lspconfig) then
    vim.notify_once(
      "[grain.nvim] nvim-lspconfig not found; skipping LSP setup.",
      vim.log.levels.WARN
    )
    return
  end
  local cmd = lsp_opts.cmd
  if type(cmd) ~= "table" or cmd[1] == nil or cmd[1] == "" then
    vim.notify_once(
      "[grain.nvim] Invalid LSP cmd; skipping LSP setup.",
      vim.log.levels.WARN
    )
    return
  end
  if vim.fn.executable(cmd[1]) ~= 1 then
    vim.notify_once(
      "[grain.nvim] Grain executable not found ("
        .. cmd[1]
        .. "). Install from https://grain-lang.org/",
      vim.log.levels.WARN
    )
    return
  end
  if not configs.grain then
    configs.grain = {
      default_config = vim.deepcopy(lsp_opts),
    }
  end
  lspconfig.grain.setup(lsp_opts)
end

function M.setup(opts)
  opts = vim.tbl_deep_extend("force", defaults, opts or {})

  if opts.filetypes then
    vim.filetype.add(opts.filetypes)
  end

  local parser_name = opts.treesitter.parser
  vim.treesitter.language.register(parser_name, { "grain" })

  ensure_tsupdate_autocmd(opts.treesitter)

  if opts.enable_lsp then
    setup_lsp(opts.lsp)
  end

  if opts.auto_install_parser then
    vim.schedule(function()
      pcall(try_install_parser, parser_name)
    end)
  end

  vim.schedule(apply_mini_icons)
end

return M
