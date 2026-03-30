# Repository Guidelines

This repository hosts two separate editor configurations: a minimal Vim configuration in the
root `vimrc`, and a Neovim configuration under `nvim/`. Keep both configurations fast, portable,
and easy to read. Changes should be incremental and justified by clear benefits to editing
ergonomics.

Treat Vim and Neovim work as independent tracks. For Vim-related requests, use `vimrc` as the
source of truth. For Neovim-related requests, use only files under `nvim/` as the source of truth
and do not infer behavior from or reference `vimrc` unless the user explicitly asks to sync them.

## Project Structure & Module Organization
- Vim config: `vimrc` (single source of truth for Vim requests).
- Neovim config: `nvim/init.lua` and `nvim/lua/` (single source of truth for Neovim requests).
- Optional Vim folders if needed later: `after/`, `autoload/`, `plugin/`, `ftplugin/`, `syntax/`,
  `colors/`.
- Keep machine‑specific or private settings out of the repo; gate OS/feature checks with `has()` and `exists()`.

## Build, Test, and Development Commands
- Quick syntax check: `vim -Nu vimrc --headless +"source vimrc" +q` (returns non‑zero on errors).
- Quick Neovim check: `nvim --headless +"source nvim/init.lua" +q` (returns non-zero on errors).
- Inspect options: `vim -Nu vimrc --headless +"verbose set number?" +q`.
- Benchmark startup: `vim --clean --startuptime startup.log -Nu vimrc -c q` then review `startup.log`.

## Coding Style & Naming Conventions
- Language: Vim work uses Vimscript (compatible with Vim 8+). Neovim work uses the conventions
  already present under `nvim/`, typically Lua.
- Indentation: 2 spaces; no tabs. Wrap at ~100 chars.
- Options: group related `set` statements; prefer explicit values (e.g., `set number`/`set nonumber`).
- Variables: use `g:` for user options (e.g., `let g:cursorline_enabled = 1`).
- Safety: guard features, e.g., `if has('clipboard') | set clipboard=unnamedplus | endif`.
- Avoid global side effects in future modules; for `autoload/` use names like `mycfg#toggle_number()`.
- Do not implement Neovim requests by inspecting or mirroring `vimrc` unless the user explicitly
  requests cross-editor parity.

## Testing Guidelines
- Headless load must be clean: no errors in `:messages` on startup.
- Validate Vim changes with Vim commands and Neovim changes with Neovim commands.
- Do not treat passing Vim checks as evidence that Neovim behavior is correct, or vice versa.
- For behavioral checks, open a scratch buffer and verify key mappings/options manually. Keep changes reversible.

## Commit & Pull Request Guidelines
- Commit messages: English, concise, imperative mood (no Conventional Commit prefixes). Example: `Make number and relativenumber coexist`.
- Stage selectively (`git add -p`); avoid committing local artifacts (logs, swap/backup files).
- PRs should include: purpose, before/after behavior, platforms tested (e.g., Vim 8.2, Neovim 0.10), and any trade‑offs.

## Security & Configuration Tips
- Do not execute shell commands on startup unless essential; prefer pure Vimscript.
- Keep defaults safe; require opt‑in for disruptive remaps or visual changes.
