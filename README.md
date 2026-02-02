# How to start

- Just clone this repo and place its contents in `~/.config`

# Neovim (nvim) + Python LSP Setup (Ubuntu/Debian)

This README documents how to install a recent Neovim (0.11+) and set up a Python LSP (Pyright) using `lazy.nvim` + `mason.nvim`.

---

## 1) Install / Upgrade Neovim to 0.11+ (Recommended)

Your system `apt` package is often old (e.g. 0.9.x). The simplest way to get a current Neovim is the AppImage.

### Install via AppImage (user-local, safe)
```sh
mkdir -p ~/.local/bin

curl -L -o ~/.local/bin/nvim \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage

chmod +x ~/.local/bin/nvim
```

Ensure `~/.local/bin` is on PATH:

#### bash
```sh
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### zsh
```sh
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc || \
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

Verify:
```sh
which nvim
nvim --version
```
You should see `~/.local/bin/nvim` and `NVIM v0.11.x`.

---

## 2) Project Layout (Neovim config)

Typical layout:
- `~/.config/nvim/init.lua`
- `~/.config/nvim/lua/plugins/init.lua`

If using lazy.nvim with:
```lua
require("lazy").setup({ import = "plugins" })
```
then your plugins must live under:
- `~/.config/nvim/lua/plugins/*.lua` (or `.../lua/plugins/init.lua`)

---

## 3) Python LSP (Pyright) via Mason

### What you get from LSP
- diagnostics (errors/warnings)
- go-to definition
- hover documentation
- references
- rename symbol
- code actions

### Mason overview
`mason.nvim` installs external tools (like `pyright-langserver`) into:
`~/.local/share/nvim/mason/bin`

If you want Neovim to always see Mason-installed tools, add this to `init.lua`:
```lua
-- Make Mason-installed binaries visible to Neovim
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
```

---

## 4) Useful Commands (Cheatsheet)

### Lazy (plugin manager)
- `:Lazy` — open Lazy UI
- `:Lazy sync` — install/update plugins to match your config
- `:Lazy clean` — remove unused plugins
- `:Lazy log` — see plugin update log

### Mason (tool installer)
- `:Mason` — open Mason UI
- `:MasonToolsInstall` — install tools listed in `mason-tool-installer.nvim` (if used)
- `:MasonToolsUpdate` — update installed tools (if supported/configured)

CLI checks:
```sh
ls -la ~/.local/share/nvim/mason/bin | head
command -v pyright-langserver
```

### LSP (built-in Neovim LSP)
General:
- `:LspInfo` — see active LSP clients and what is attached
- `:checkhealth lsp` — basic LSP health checks

Quick “is the server executable found?”:
```vim
:echo executable('pyright-langserver')
```
`1` = found, `0` = not found.

Common in-buffer actions (when LSP attached):
- Go to definition: `gd`
- Find references: `gr`
- Hover docs: `K`
- Rename: `<leader>rn`
- Code action: `<leader>ca`

(Exact mappings depend on your config.)

Diagnostics:
- Open diagnostic float (current line):  
  `:lua vim.diagnostic.open_float()`
- Jump diagnostics:
  - `:lua vim.diagnostic.goto_prev()`
  - `:lua vim.diagnostic.goto_next()`

---

## 5) File Tree (nvim-tree)

### Toggle the tree
If your config maps:
- `<C-n>` → toggle file tree

Then use:
- `Ctrl+n` — show/hide tree

### Common nvim-tree actions (inside the tree)
Defaults vary slightly by version/config, but commonly:
- `Enter` — open file/directory
- `a` — create file
- `d` — delete
- `r` — rename
- `x` — cut
- `c` — copy
- `p` — paste
- `R` — refresh

If keys don’t match, open help in the tree buffer:
- `g?` (often shows mappings)

---

## 6) Typical workflow

1. Update plugins:
   - `:Lazy sync`

2. Install Pyright (if not already):
   - `:Mason` → search/install `pyright`
   - or `:MasonToolsInstall` (if configured)

3. Open a Python file:
   - `nvim your_script.py`

4. Verify LSP attaches:
   - `:LspInfo`

5. Use LSP features:
   - `gd`, `gr`, `K`, `<leader>rn`, `<leader>ca`

---

## Troubleshooting

### `:Mason` says “Not an editor command”
- `mason.nvim` plugin is not loaded/installed
- Run `:Lazy sync`
- Ensure `mason.nvim` is in your plugin list and not disabled

### `pyright-langserver` exists but Neovim can’t run it
- Add Mason bin path into Neovim PATH:
  ```lua
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
  ```
- Restart Neovim and check:
  ```vim
  :echo executable('pyright-langserver')
  ```

### LSP not attaching to Python files
- Check `:LspInfo` in a `.py` buffer
- Ensure the config calls `vim.lsp.enable("pyright")`
- Ensure filetype is detected as python:
  ```vim
  :set filetype?
  ```

---

## Notes
- For best Python results, use a project virtual environment (e.g. `.venv/`) and a `pyproject.toml`.
- Pyright’s behavior can be tuned via `pyrightconfig.json` or LSP settings.
