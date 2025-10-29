# Repository Guidelines

This repository hosts a minimal Vim configuration centered on the root `vimrc`. Keep the configuration fast, portable, and easy to read. Changes should be incremental and justified by clear benefits to editing ergonomics.

## Project Structure & Module Organization
- Root config: `vimrc` (single source of truth).
- Optional folders if needed later: `after/`, `autoload/`, `plugin/`, `ftplugin/`, `syntax/`, `colors/`.
- Keep machine‑specific or private settings out of the repo; gate OS/feature checks with `has()` and `exists()`.

## Build, Test, and Development Commands
- Quick syntax check: `vim -Nu vimrc --headless +"source vimrc" +q` (returns non‑zero on errors).
- Inspect options: `vim -Nu vimrc --headless +"verbose set number?" +q`.
- Benchmark startup: `vim --clean --startuptime startup.log -Nu vimrc -c q` then review `startup.log`.

## Coding Style & Naming Conventions
- Language: Vimscript (compatible with Vim 8+; avoid Neovim‑only APIs unless guarded).
- Indentation: 2 spaces; no tabs. Wrap at ~100 chars.
- Options: group related `set` statements; prefer explicit values (e.g., `set number`/`set nonumber`).
- Variables: use `g:` for user options (e.g., `let g:cursorline_enabled = 1`).
- Safety: guard features, e.g., `if has('clipboard') | set clipboard=unnamedplus | endif`.
- Avoid global side effects in future modules; for `autoload/` use names like `mycfg#toggle_number()`.

## Testing Guidelines
- Headless load must be clean: no errors in `:messages` on startup.
- Validate on Vim 8 and Neovim if possible.
- For behavioral checks, open a scratch buffer and verify key mappings/options manually. Keep changes reversible.

## Commit & Pull Request Guidelines
- Commit messages: English, concise, imperative mood (no Conventional Commit prefixes). Example: `Make number and relativenumber coexist`.
- Stage selectively (`git add -p`); avoid committing local artifacts (logs, swap/backup files).
- PRs should include: purpose, before/after behavior, platforms tested (e.g., Vim 8.2, Neovim 0.10), and any trade‑offs.

## Security & Configuration Tips
- Do not execute shell commands on startup unless essential; prefer pure Vimscript.
- Keep defaults safe; require opt‑in for disruptive remaps or visual changes.
