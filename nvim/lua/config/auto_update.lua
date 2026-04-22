local M = {}

local REPO_PATH = vim.fn.expand("~/tools/vimrc")
local STAMP_FILE = vim.fn.stdpath("cache") .. "/vimrc-last-fetch"
local INTERVAL_SECONDS = 60 * 60

local function read_stamp()
  local f = io.open(STAMP_FILE, "r")
  if not f then
    return 0
  end
  local content = f:read("*a")
  f:close()
  return tonumber(content) or 0
end

local function write_stamp(time)
  local f = io.open(STAMP_FILE, "w")
  if not f then
    return
  end
  f:write(tostring(time))
  f:close()
end

local function notify(msg, level)
  vim.schedule(function()
    vim.notify(msg, level or vim.log.levels.INFO, { title = "vimrc auto-update" })
  end)
end

local function git(args, on_exit)
  local cmd = { "git", "-C", REPO_PATH }
  vim.list_extend(cmd, args)
  vim.system(cmd, { text = true }, on_exit)
end

function M.run()
  local now = os.time()
  if now - read_stamp() < INTERVAL_SECONDS then
    return
  end
  write_stamp(now)

  git({ "fetch", "--quiet" }, function(fetch_result)
    if fetch_result.code ~= 0 then
      return
    end

    git({ "rev-list", "--count", "HEAD..@{u}" }, function(count_result)
      if count_result.code ~= 0 then
        return
      end
      local count = tonumber((count_result.stdout or ""):match("%d+"))
      if not count or count == 0 then
        return
      end

      git({ "status", "--porcelain" }, function(status_result)
        if status_result.code ~= 0 then
          return
        end
        if status_result.stdout and status_result.stdout ~= "" then
          notify(
            string.format("vimrc 업데이트 %d개 있음 (워킹트리 변경사항 있어 자동 merge 생략)", count),
            vim.log.levels.WARN
          )
          return
        end

        git({ "merge", "--ff-only", "@{u}" }, function(merge_result)
          if merge_result.code == 0 then
            notify(string.format("vimrc 업데이트됨 (%d 커밋), nvim 재시작 권장", count))
          else
            notify("vimrc merge 실패 (fast-forward 불가, 수동 merge 필요)", vim.log.levels.WARN)
          end
        end)
      end)
    end)
  end)
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("vimrc_auto_update", { clear = true }),
  callback = function()
    M.run()
  end,
})

return M
