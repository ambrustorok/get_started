-- ~/.config/nvim/lua/lsp_setup.lua

local M = {}

local ensure = { "pyright" }
local pending_buffers = {}
local notified_missing = false

local function root_dir(fname)
  fname = fname ~= "" and fname or vim.fn.expand("%:p")
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

local function ensure_tools()
  local ok, registry = pcall(require, "mason-registry")
  if not ok then
    return
  end

  local function install()
    for _, name in ipairs(ensure) do
      local success, pkg = pcall(registry.get_package, name)
      if success then
        if not pkg:is_installed() then
          pkg:on("install:success", function()
            vim.schedule(function()
              for buf, _ in pairs(pending_buffers) do
                if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "python" then
                  pending_buffers[buf] = nil
                  vim.schedule(function()
                    M.start_pyright(buf)
                  end)
                end
              end
            end)
          end)
          pkg:install()
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
  local map = function(mode, lhs, rhs, desc)
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

function M.start_pyright(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    pending_buffers[bufnr] = nil
    return
  end

  if vim.bo[bufnr].filetype ~= "python" then
    return
  end

  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "pyright" })
  if clients and #clients > 0 then
    pending_buffers[bufnr] = nil
    return
  end

  if vim.fn.executable("pyright-langserver") == 0 then
    pending_buffers[bufnr] = true
    if not notified_missing then
      notified_missing = true
      vim.schedule(function()
        vim.notify("Waiting for Mason to install pyright-langserver...", vim.log.levels.INFO)
      end)
    end
    return
  end

  pending_buffers[bufnr] = nil

  vim.lsp.start({
    name = "pyright",
    cmd = { "pyright-langserver", "--stdio" },
    root_dir = root_dir(vim.api.nvim_buf_get_name(bufnr)),
    filetypes = { "python" },
    capabilities = vim.lsp.protocol.make_client_capabilities(),
    settings = {
      python = {
        analysis = {
          autoImportCompletions = true,
          useLibraryCodeForTypes = true,
        },
      },
    },
  }, { bufnr = bufnr })
end

function M.setup()
  ensure_tools()

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = lsp_keymaps,
  })

  vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
    callback = function(event)
      if vim.bo[event.buf].filetype == "python" then
        M.start_pyright(event.buf)
      end
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function(event)
      M.start_pyright(event.buf)
    end,
  })
end

return M
