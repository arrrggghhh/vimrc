vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local opt = vim.opt

local function configure_clipboard()
  if vim.fn.has("mac") == 1 then
    vim.g.clipboard = {
      name = "pbcopy",
      copy = { ["+"] = "pbcopy", ["*"] = "pbcopy" },
      paste = { ["+"] = "pbpaste", ["*"] = "pbpaste" },
      cache_enabled = 0,
    }
    return
  end

  local is_wsl = vim.fn.has("wsl") == 1
    or vim.env.WSL_DISTRO_NAME ~= nil
    or vim.env.WSL_INTEROP ~= nil
  if is_wsl then
    if vim.fn.executable("win32yank.exe") == 1 then
      vim.g.clipboard = {
        name = "win32yank",
        copy = {
          ["+"] = { "win32yank.exe", "-i", "--crlf" },
          ["*"] = { "win32yank.exe", "-i", "--crlf" },
        },
        paste = {
          ["+"] = { "win32yank.exe", "-o", "--lf" },
          ["*"] = { "win32yank.exe", "-o", "--lf" },
        },
        cache_enabled = 0,
      }
    else
      vim.g.clipboard = {
        name = "wsl-clip",
        copy = { ["+"] = "clip.exe", ["*"] = "clip.exe" },
        paste = {
          ["+"] = { "powershell.exe", "-NoProfile", "-Command", "Get-Clipboard" },
          ["*"] = { "powershell.exe", "-NoProfile", "-Command", "Get-Clipboard" },
        },
        cache_enabled = 0,
      }
    end
    return
  end

  local is_ssh = vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
  local has_native = vim.fn.executable("xclip") == 1
    or vim.fn.executable("xsel") == 1
    or vim.fn.executable("wl-copy") == 1
  if is_ssh or not has_native then
    local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
    if ok then
      vim.g.clipboard = {
        name = "OSC 52",
        copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
        paste = { ["+"] = osc52.paste("+"), ["*"] = osc52.paste("*") },
      }
    end
    return
  end
end

configure_clipboard()

opt.clipboard = ""
opt.cmdheight = 1
opt.completeopt = { "menu", "menuone", "noselect" }
opt.expandtab = true
opt.hidden = true
opt.hlsearch = true
opt.ignorecase = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true

local function statuscol_num()
  if vim.v.virtnum ~= 0 then return "" end
  local width = math.max(#tostring(vim.fn.line("$")), 3)
  local text = string.format("%" .. width .. "d", vim.v.lnum)
  if vim.v.relnum ~= 0 and vim.v.relnum % 10 == 0 then
    return "%#LineNrMilestone#" .. text .. "%*"
  end
  return text
end
_G._statuscol_num = statuscol_num

local function set_milestone_hl()
  vim.api.nvim_set_hl(0, "LineNrMilestone", { link = "Special" })
end
set_milestone_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_milestone_hl })

opt.statuscolumn = "%s%C%{%v:lua._statuscol_num()%} "
opt.shiftwidth = 2
opt.smartcase = true
opt.smartindent = true
opt.splitbelow = true
opt.splitright = true
opt.tabstop = 2
opt.termguicolors = true
opt.autoread = true
opt.undofile = true
opt.updatetime = 250
opt.wrap = true
opt.linebreak = true

local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
opt.undodir = undodir
