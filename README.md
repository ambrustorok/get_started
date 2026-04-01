# How To Start

Clone this repo into `~/.config` and open Neovim with `nvim`.

# Minimal Neovim + Python

This setup is intentionally small, but it covers the useful daily basics:
- `lazy.nvim` for plugin management
- `nvim-tree` on `<C-n>` for a simple file tree
- `gitsigns` for inline Git hunks
- `lazygit` inside Neovim on `<leader>gg`
- Mason-managed `pyright` and `ruff` for Python
- Markdown split preview with `markview.nvim` (`<leader>tp` to open side-by-side)
- explicit clipboard behavior: `y` stays local, `Y` copies to the system clipboard
- visible warnings for trailing whitespace and non-ASCII characters

## Core Ideas

- The leader key is `Space`.
- When you see `<leader>e`, read that as: press `Space`, then `e`.
- Splits open where you expect: horizontal splits below, vertical splits to the right.
- This config is built around stock Neovim behavior first, with a few practical additions.

## Layout

```text
~/.config/README.md
~/.config/.tmux.conf
~/.config/nvim/init.lua
~/.config/nvim/lua/mappings.lua
~/.config/nvim/lua/plugins/init.lua
~/.config/nvim/lua/plugins/markdown.lua
~/.config/nvim/lua/lsp_setup.lua
```

## Install / Upgrade Neovim

Neovim 0.11+ is required.

```sh
nvim --version
```

If that first line is not `NVIM v0.11.x` or newer, upgrade Neovim before using this config.

## Plugins And Tools

### `lazy.nvim`

Plugin manager. Main commands:
- `:Lazy`
- `:Lazy sync`
- `:Lazy clean`

### `mason.nvim`

Installs external developer tools Neovim needs.

Main commands:
- `:Mason`
- `:MasonUpdate`
- `:MasonLog`

### `nvim-tree`

File explorer on `<C-n>`.

### `gitsigns.nvim`

Shows added, changed, and deleted lines in the sign column. It also gives hunk actions like stage, reset, preview, and blame.

### `lazygit.nvim`

Thin Neovim wrapper around the `lazygit` terminal UI.

Requirements:
- the `lazygit` binary must already be installed and available on your `PATH`

Main mappings:
- `<leader>gg` opens LazyGit
- `<leader>gf` opens LazyGit focused on the current file

Main command:
- `:LazyGit`

Quick check:

```sh
command -v lazygit
```

### `markview.nvim`

Markdown (and HTML, LaTeX, Typst, YAML) previewer with two modes:

- **Split preview** — opens a read-only rendered pane side-by-side with the source buffer, scroll-synced
- **In-buffer rendering** — renders headings, bullets, tables, checkboxes, and code blocks directly in the editing buffer (hybrid mode keeps the line under your cursor editable)

Depends on `nvim-treesitter` (installed alongside it) with the `markdown` and `markdown_inline` grammars. Fetch them once with `:TSUpdate`.

Main mappings:
- `<leader>tp`: open/close the split preview pane
- `<leader>tm`: toggle in-buffer rendering on/off

Main commands:
- `:Markview splitToggle` — same as `<leader>tp`
- `:Markview Toggle` — same as `<leader>tm`
- `:Markview Enable` / `:Markview Disable` — global on/off

## Keymaps

### General

- `<C-n>`: toggle file tree
- `<leader>e`: show diagnostics for the current line
- `[d`: previous diagnostic
- `]d`: next diagnostic

### LSP

These are attached when an LSP client starts:
- `gd`: go to definition
- `gr`: go to references
- `K`: hover documentation
- `<leader>rn`: rename symbol
- `<leader>ca`: code action
- `<leader>f`: format buffer
- `Ctrl-o`: jump back after navigation
- `Ctrl-i`: jump forward again

### Markdown

- `<leader>tp`: open/close split preview pane (side-by-side rendered view)
- `<leader>tm`: toggle in-buffer rendering on/off

### Git

- `]c`: next Git hunk
- `[c`: previous Git hunk
- `<leader>hs`: stage hunk
- `<leader>hr`: reset hunk
- `<leader>hS`: stage buffer
- `<leader>hu`: undo staged hunk
- `<leader>hR`: reset buffer
- `<leader>hp`: preview hunk
- `<leader>hb`: blame line
- `<leader>hB`: toggle inline blame
- `<leader>hd`: diff current buffer
- `<leader>gg`: open LazyGit
- `<leader>gf`: open LazyGit for current file

## Clipboard

This config uses explicit clipboard actions because they are easier to reason about:
- `y` behaves like normal Vim yank and stays inside Neovim registers
- `Y` copies to the system clipboard

Examples:
- normal mode `Y`: copy the current line to the OS clipboard
- visual mode `Y`: copy the selection to the OS clipboard
- `"+y`: explicit system clipboard yank
- `"+p`: paste from the system clipboard
- `:reg +`: inspect the system clipboard register

This keeps ordinary editing predictable while still making "copy this outside Neovim" very fast.

## Visual Block Editing

This is the vertical editing mode your colleague was likely using.

- `Ctrl-v`: start Visual Block mode
- `Ctrl-q`: use this instead if your terminal steals `Ctrl-v`
- move with `hjkl`, `w`, `b`, `0`, `$`
- `I`: insert at the start of every selected line
- `A`: append at the end of every selected line
- `d`: delete the selected block
- `c`: change the selected block
- `>` / `<`: indent or dedent the block

Typical example:
1. Press `Ctrl-v`
2. Select a column on several lines
3. Press `I`
4. Type text
5. Press `Esc`

Neovim will apply that insert to every selected line.

## Increment / Decrement Numbers

This is built into Vim and Neovim already. No plugin is needed.

- `Ctrl-a`: increment the number under the cursor
- `Ctrl-x`: decrement the number under the cursor

Examples:
- cursor on `41`, press `Ctrl-a`, it becomes `42`
- cursor on `100`, press `Ctrl-x`, it becomes `99`

For multiple numbers in a visual selection:
- `g Ctrl-a`: increment each matching number in the selection
- `g Ctrl-x`: decrement each matching number in the selection

That is useful for numbered lists, test data, ports, IDs, and similar repetitive edits.

## Search And Replace

### Search

- `/text`: search forward
- `?text`: search backward
- `n`: next match
- `N`: previous match
- `*`: search for the word under the cursor

### Replace

- `:%s/old/new/g`: replace all matches in the file
- `:%s/old/new/gc`: replace all matches in the file with confirmation
- `:s/old/new/g`: replace on the current line

If you want the current word:

```vim
:%s/\<word\>/new_word/gc
```

The `c` flag is usually the right default because it prevents accidental broad replacements.

## File Tree

Open it with `<C-n>`.

Useful default `nvim-tree` actions:
- `j` / `k`: move
- `l` or `<CR>`: open / expand
- `h`: close directory / go to parent
- `v`: vertical split
- `s`: horizontal split
- `a`: add file or directory
- `r`: rename
- `d`: delete
- `R`: refresh
- `H`: toggle dotfiles
- `I`: toggle gitignored files
- `?`: help inside the tree

## Python Setup

`lua/lsp_setup.lua` handles Python automatically:
- installs `pyright` through Mason if needed
- installs `ruff` through Mason if needed
- starts both LSP servers for Python buffers
- attaches buffer-local LSP keymaps when they are ready
- expects `ruff`, not `ruff-lsp`; if you still have `ruff-lsp` installed in Mason, remove it

Quick validation:

```sh
command -v pyright-langserver
command -v ruff
```

Inside Neovim:
- `:LspInfo`
- `:Mason`

## Visible Warnings

This config highlights things we usually want to fix instead of ignore:
- trailing whitespace at the end of lines
- non-ASCII / Unicode characters

That makes it easier to keep files clean, especially in scripts, config files, and codebases where plain ASCII is preferred.

## tmux Copying

Current tmux config is minimal and keeps tmux defaults:
- prefix is still `Ctrl-b`
- no special tmux clipboard integration is configured
- no tmux mouse mode is configured

### Copy inside tmux using copy mode

1. Press `Ctrl-b` then `[`
2. Move with Vim keys or arrows
3. Press `Space` to start selection
4. Move to expand the selection
5. Press `Enter` to copy into tmux's paste buffer
6. Press `Ctrl-b` then `]` to paste it

### Copy using the terminal mouse

If you want to copy with the mouse in a terminal, that is usually handled by the terminal emulator itself, not Neovim or tmux.

Common pattern:
- drag to select text with the mouse
- if mouse support gets in the way, hold `Shift` while dragging

That depends on the terminal emulator, but `Shift` is the common escape hatch.

### Copy from Neovim to the system clipboard while inside tmux

Use Neovim's system clipboard register directly:
- visual select text, then press `Y`
- or use `"+y`

That bypasses tmux's internal paste buffer and targets the OS clipboard.

## Typical Workflow

1. Run `:Lazy sync`
2. Run `:TSUpdate` (one-time, fetches the markdown grammars)
3. Run `:Mason` and make sure `pyright` and `ruff` are installed
4. Open a Python file
5. Run `:LspInfo`
6. Use `gd`, `gr`, `K`, `<leader>ca`, and `<leader>f`
7. Use `<leader>gg` when you want a full Git UI without leaving Neovim
8. Open any `.md` file to see in-buffer Markdown rendering; toggle it with `<leader>tm`

## Troubleshooting

### `:Mason` not found

- run `:Lazy sync`
- check that `williamboman/mason.nvim` is still present in `nvim/lua/plugins/init.lua`

### `:LazyGit` not found

- run `:Lazy sync`
- check that `kdheepak/lazygit.nvim` is still present in `nvim/lua/plugins/init.lua`
- make sure the external `lazygit` binary is installed

### `pyright` or `ruff` missing

- open `:Mason`
- install the package from the Mason UI
- restart Neovim and reopen the Python file

### LSP not attaching

- run `:LspInfo` inside a Python buffer
- check `:set filetype?`
- confirm `pyright` and `ruff` exist in `nvim/lua/lsp_setup.lua`

### Markdown preview not working

- run `:Lazy sync` to make sure `markview.nvim` and `nvim-treesitter` are installed
- run `:TSUpdate` to fetch the `markdown` and `markdown_inline` grammars
- run `:checkhealth markview` to see if anything is missing
- check that the buffer filetype is `markdown` with `:set filetype?`
- toggle split preview with `<leader>tp`, or in-buffer rendering with `<leader>tm`
