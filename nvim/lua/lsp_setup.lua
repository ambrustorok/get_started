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
  ruff_lsp = {
    package = "ruff-lsp",
    cmd = { "ruff-lsp" },
    executable = "ruff-lsp",
    filetypes = { "python" },
    init_options = {
      settings = {
        args = {},
      },
    },
  },
}

local package_to_server = {}
local ensure = {}
for name, spec in pairs(servers) do
  package_to_server[spec.package] = name
  table.insert(ensure, spec.package)
end

local pending = {}
local notified_missing = {}

local function root_dir(fname)
  fname = (fname and fname ~= "") and fname or vim.fn.expand("%:p")
  local root_files = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    ".git",
  }
  local path = vim.fs.find(root_files, { upward = true, path = fname })[1]
  return path and vim.fs.dirname(path) or vim.loop.cwd()
end

local start_server -- forward declare

local function is_empty(tbl)
  return not tbl or next(tbl) == nil
end

local function mark_pending(name, bufnr)
  pending[name] = pending[name] or {}
  pending[name][bufnr] = true
end

local function clear_pending(name, bufnr)
  if not pending[name] then
    return
  end
  if bufnr then
    pending[name][bufnr] = nil
    if is_empty(pending[name]) then
      pending[name] = nil
    end
  else
    pending[name] = nil
  end
end

local function flush_pending(name)
  if not pending[name] then
    return
  end
  local buffers = pending[name]
  pending[name] = nil
  for buf, _ in pairs(buffers) do
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
    for _, package in ipairs(ensure) do
      local success, pkg = pcall(registry.get_package, package)
      if success then
        local server = package_to_server[pkg:name()]
        if not pkg:is_installed() then
          pkg:on("install:success", function()
            if server then
              vim.schedule(function()
                flush_pending(server)
              end)
            end
          end)
          pkg:install()
        elseif server then
          flush_pending(server)
        end
      end
    end
  end

  if registry.refresh then
    registry.refresh(install)
  else
    install()
  end
end

local function lsp_keymaps(event)
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
  if not vim.api.nvim_buf_is_valid(bufnr) then
    clear_pending(name, bufnr)
    return
  end

  if vim.bo[bufnr].filetype ~= "python" then
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = name })
  if clients and #clients > 0 then
    clear_pending(name, bufnr)
    return
  end

  local exe = spec.executable or spec.cmd[1]
  if vim.fn.executable(exe) == 0 then
    mark_pending(name, bufnr)
    if not notified_missing[exe] then
      notified_missing[exe] = true
      vim.schedule(function()
        vim.notify(("Waiting for Mason to install %s..."):format(exe), vim.log.levels.INFO)
      end)
    end
    return
  end

  clear_pending(name, bufnr)

  local filename = vim.api.nvim_buf_get_name(bufnr)
  vim.lsp.start({
    name = name,
    cmd = spec.cmd,
    root_dir = spec.root_dir and spec.root_dir(filename) or root_dir(filename),
    filetypes = spec.filetypes,
    capabilities = capabilities,
    init_options = spec.init_options,
    settings = spec.settings,
  }, { bufnr = bufnr })
end

local function start_all(bufnr)
  for name, _ in pairs(servers) do
    start_server(name, bufnr)
  end
end

function M.setup()
  ensure_tools()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = lsp_keymaps,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(event)
      start_all(event.buf)
    end,
  })

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "python" then
      start_all(buf)
    end
  end
end

return M
