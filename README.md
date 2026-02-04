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
- `:lua vim.lsp.buf.definition()` / `references()` / `hover()` — core navigation/help
- `:lua vim.lsp.buf.rename()` / `code_action()` — refactor/actions
- `:lua vim.lsp.buf.format({ async = true })` — format buffer

### System clipboard yanks
- The config appends `unnamedplus` to `clipboard`, so ordinary yanks (`yy`, `yw`, Visual `y`) already mirror into your OS clipboard—`Ctrl-v` outside Neovim pastes the same text.
- For explicit control, use the `+` register: `"+y` copies the current selection, `"+p` pastes from the system clipboard, and `:reg +` shows what’s stored. This is handy if you ever remove `unnamedplus` or need to target the clipboard while leaving the default register untouched.
- Mouse selections or `"*y` tap the primary selection (X11). Stick to `+` for predictable cross-platform copy/paste.

### Ruff-powered actions
- `<leader>f` fires `vim.lsp.buf.format()` which, in this setup, shells out to Ruff for lint-aware formatting (think `ruff check --fix` scoped to the current buffer). Use it after larger edits to guarantee imports stay sorted and style stays consistent.
- `<leader>ca` opens LSP code actions. When Ruff reports a diagnostic, this menu gets populated with the exact quick-fixes Ruff suggests (rename to snake_case, remove unused imports, auto-fix formatting, etc.). Many fixes apply instantly without leaving Normal mode, so triage diagnostics with `[d` / `]d`, then drop into `<leader>ca` to repair the highlighted line.

**Common mappings** (set in `lua/lsp_setup.lua`): `gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`, `<leader>f`, `[d`, `]d`, `<leader>e`.

**Most common commands (quick list):**
- `gd` — go to definition
- `gr` — find references
- `K` — hover docs
- `<leader>rn` — rename symbol
- `<leader>ca` — code actions
- `<leader>f` — format
- `[d` / `]d` — previous/next diagnostic
- `<leader>e` — show diagnostic (float)
- `Ctrl-o` / `Ctrl-i` — jump back/forward (after `gd`, etc.)

## 5) File tree (nvim-tree)

- Toggle the explorer with `<C-n>`; the tree appears on the left and closes with the same mapping.
- Move through entries with `j`/`k` (down/up) and jump to the top/bottom with `gg` / `G` just like a normal buffer.
- `h` collapses the current directory (or jumps to its parent), while `l` expands a folder or opens a file; `L` opens the node and all children in one go.
- Use `<CR>` (or `o`) to open the highlighted file. `v` splits vertically, `s` splits horizontally, and `<Tab>` keeps the tree focused while previewing the file.
- `a` creates files/directories relative to the selected node, `d` deletes, and `r` renames; confirm prompts with `<CR>`.
- Press `R` to refresh the tree when files change outside Neovim. Toggle dotfiles with `H` and git-ignored files with `I` when you need a cleaner view.
- `C` re-roots the tree at the folder under your cursor, `p` jumps to that node's parent, and `q` closes the tree window entirely.
- `Ctrl-w h/l` moves focus between the tree and editing windows; `:wincmd =` evens sizes after resizing.
- Hit `?` inside the tree for the built-in cheatsheet of every default mapping if you forget something.

## 6) Typical workflow

1. Run `:Lazy sync` to install plugins.
2. Open `:Mason` and confirm `pyright` + `ruff` show “Installed” (the helper auto-installs them if missing).
3. Edit a Python file (`nvim main.py`).
4. Run `:LspInfo` — you should see `pyright` and `ruff` attached.
5. Use the LSP mappings for navigation, refactors, formatting, and diagnostics.

## 8) Code autocomplete (built-in)

This minimalist stack intentionally skips heavier completion plugins and relies on Neovim's native LSP-powered completion instead:
- Insert mode `Ctrl-x Ctrl-o` triggers omni-completion fed by the active LSP clients (Pyright + Ruff). You'll get signature help, attribute/method names, and typed completions straight from the language server.
- If you prefer popups while you type, enable the built-in menu by setting `set completeopt=menuone,noinsert,noselect` (already configured via LSP defaults) and tap `Ctrl-Space` (or `Ctrl-n`) to refresh suggestions without leaving Insert mode.
- Accept the highlighted item with `<CR>` or keep cycling through candidates with `Ctrl-n` / `Ctrl-p`. Because everything is LSP-backed, the suggestions understand imports, dataclasses, and type hints with no extra plugins.

## 7) Troubleshooting

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
