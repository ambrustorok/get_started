# How to start

- Just clone this repo and place its contents in `~/.config`

# Minimal Neovim + Python (Pyright + Ruff)

This repo contains a tiny Neovim setup (0.11+) that focuses on:
- System clipboard integration (`unnamedplus` is enabled by default)
- Automatic Pyright **and** Ruff install/start whenever you edit Python files
- `nvim-tree` on `<C-n>` for a lightweight file explorer
- Only two plugins (`nvim-tree` and `mason.nvim`); all LSP wiring lives in `lua/lsp_setup.lua`

## 1) Install / Upgrade Neovim to 0.11+

AppImage install (safe for Ubuntu/Debian):
```sh
mkdir -p ~/.local/bin
curl -L -o ~/.local/bin/nvim \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
chmod +x ~/.local/bin/nvim
```
Add `~/.local/bin` to `PATH` (bash example):
```sh
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```
Then verify:
```sh
which nvim
nvim --version
```
You should see `~/.local/bin/nvim` and `NVIM v0.11.x`.

## 2) Project layout

```
~/.config/nvim/init.lua
~/.config/nvim/lua/plugins/init.lua
~/.config/nvim/lua/mappings.lua
~/.config/nvim/lua/lsp_setup.lua
```
`lazy.nvim` loads everything under `lua/plugins/`, so keep additional plugin specs there if you expand this setup.

## 3) Python LSP via Mason

`lua/lsp_setup.lua` does all of the work:
- ensures the Mason packages `pyright` and `ruff` are installed,
- watches for Python buffers and launches both servers via `vim.lsp.start`,
- wires buffer-local keymaps on `LspAttach` (`gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, `<leader>f`).

`pyright` provides type checking and navigation, while `ruff` (through `ruff server`) handles linting plus formatting (so `<leader>f` uses Ruff).

Mason installs binaries to `~/.local/share/nvim/mason/bin`. The config prepends that directory to `$PATH`, so Neovim can run the tools immediately.

## 4) Useful commands

### Lazy (plugin manager)
- `:Lazy` / `:Lazy sync` / `:Lazy clean`

### Mason (tool installer)
- `:Mason` — UI for packages
- `:MasonUpdate` — refresh registry
- `:MasonLog` — open Mason log

CLI checks:
```sh
ls ~/.local/share/nvim/mason/bin
command -v pyright-langserver
command -v ruff
```

### Built-in LSP
- `:LspInfo` — inspect attached clients
- `:checkhealth lsp` — quick diagnostics
- `:lua vim.diagnostic.goto_prev()` / `goto_next()` — jump diagnostics

Common mappings (set in `lua/lsp_setup.lua`): `gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, `<leader>f`, `[d`, `]d`, `<leader>e`.

## 5) Typical workflow

1. Run `:Lazy sync` to install plugins.
2. Open `:Mason` and confirm `pyright` + `ruff` show “Installed” (the helper auto-installs them if missing).
3. Edit a Python file (`nvim main.py`).
4. Run `:LspInfo` — you should see `pyright` and `ruff` attached.
5. Use the LSP mappings for navigation, refactors, formatting, and diagnostics.

## 6) Troubleshooting

### `:Mason` not found
- Run `:Lazy sync` (ensures `mason.nvim` is installed)
- Confirm `mason.nvim` still exists in `lua/plugins/init.lua`

### `pyright` or `ruff` missing
- Run `:Mason` → press `i` on the package to install
- Ensure `~/.local/share/nvim/mason/bin` is on `$PATH` (see `init.lua` snippet)
- Restart Neovim and re-open the Python file

### LSP not attaching
- `:LspInfo` inside a `.py` buffer (expect both `pyright` and `ruff`)
- Make sure the buffer filetype is `python` (`:set filetype?`)
- Open `lua/lsp_setup.lua` and confirm the `servers` table lists the clients you expect

### Ruff warning about `ruff-lsp`
- This config already uses the `ruff` package and launches `ruff server`, so no action is required. If Mason shows an old `ruff-lsp` install, you can uninstall it from the UI.
