-- ~/.config/nvim/lua/lsp_setup.lua

local M = {}

local capabilities = vim.lsp.protocol.make_client_capabilities()

local servers = {
  pyright = {
    package = "pyright",
    cmd = { "pyright-langserver", "--stdio" },
    executable = "pyright-langserver",
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  ruff = {
    package = "ruff",
    cmd = { "ruff", "server" },
    executable = "ruff",
    filetypes = { "python" },
  },
}

local pending = {}
local notified = {}

local function root_dir(path)
  path = (path and path ~= "") and path or vim.fn.expand("%:p")
  local root_files = {
    "pyproject.toml",
    "ruff.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }
  local found = vim.fs.find(root_files, { upward = true, path = path })[1]
  return found and vim.fs.dirname(found) or vim.loop.cwd()
end

local start_server

local function mark_pending(name, bufnr)
  pending[name] = pending[name] or {}
  pending[name][bufnr] = true
end

local function flush_pending(name)
  if not pending[name] then
    return
  end
  local buffers = pending[name]
  pending[name] = nil
  for buf in pairs(buffers) do
    if vim.api.nvim_buf_is_valid(buf) then
      start_server(name, buf)
    end
  end
end

local function ensure_tools()
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local function install()
    for name, spec in pairs(servers) do
      local ok_pkg, pkg = pcall(registry.get_package, spec.package)
      if ok_pkg and pkg then
        if not pkg:is_installed() then
          pkg:on("install:success", function()
            vim.schedule(function()
              flush_pending(name)
            end)
          end)
          pkg:install()
        else
          flush_pending(name)
        end
      elseif not ok_pkg then
        vim.notify(("mason: failed to load %s (%s)"):format(spec.package, pkg), vim.log.levels.WARN)
      end
    end
  end

  if registry.refresh then
    registry.refresh(install)
  else
    install()
  end
end

local function on_lsp_attach(event)
  local buf = event.buf
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
  end

  map("n", "gd", vim.lsp.buf.definition, "Goto definition")
  map("n", "gr", vim.lsp.buf.references, "Goto references")
  map("n", "K", vim.lsp.buf.hover, "Hover info")
  map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
  map("n", "<leader>f", function()
    vim.lsp.buf.format({ async = true })
  end, "Format buffer")
end

start_server = function(name, bufnr)
  local spec = servers[name]
  if not spec then
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "python" then
    return
  end

  if next(vim.lsp.get_clients({ bufnr = bufnr, name = name })) then
    return
  end

  local exe = spec.executable or spec.cmd[1]
  if vim.fn.executable(exe) == 0 then
    mark_pending(name, bufnr)
    if not notified[exe] then
      notified[exe] = true
      vim.schedule(function()
        vim.notify(("Waiting for Mason to install %s..."):format(exe), vim.log.levels.INFO)
      end)
    end
    return
  end

  local filename = vim.api.nvim_buf_get_name(bufnr)
  vim.lsp.start({
    name = name,
    cmd = spec.cmd,
    root_dir = spec.root_dir and spec.root_dir(filename) or root_dir(filename),
    filetypes = spec.filetypes,
    capabilities = capabilities,
    settings = spec.settings,
    init_options = spec.init_options,
  }, { bufnr = bufnr })
end

local function start_all(bufnr)
  for name in pairs(servers) do
    start_server(name, bufnr)
  end
end

function M.setup()
  ensure_tools()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = on_lsp_attach,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    callback = function(event)
      if vim.bo[event.buf].filetype == "python" then
        start_all(event.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(event)
      start_all(event.buf)
    end,
  })
end

return M
