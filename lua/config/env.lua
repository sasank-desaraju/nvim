-- This is so that I can specify which plugins/settings I want based on the machine I'm on
local uv = vim.uv or vim.loop

local M = {}

M.hostname = (uv.os_gethostname and uv.os_gethostname()) or vim.fn.hostname()
M.sysname  = (uv.os_uname and uv.os_uname().sysname) or ""

-- OS checks
M.is_mac   = vim.fn.has("macunix") == 1
M.is_linux = (not M.is_mac) and M.sysname:lower():match("linux") ~= nil

-- Hostname checks (you can refine as needed)
M.is_popos = M.hostname == "pop-os"
M.is_hpc = M.is_linux and (M.hostname:match("%.ufhpc$") ~= nil)
-- M.is_macbook = M.is_mac  -- optionally match hostname if you want

-- SSH detection
M.is_ssh = vim.env.SSH_CONNECTION ~= nil

-- Summary for debugging
function M.summary()
  print("Hostname: " .. M.hostname)
  print("Sysname:  " .. M.sysname)
  for k, v in pairs(M) do
    if type(v) == "boolean" then
      print(string.format("%-18s %s", k, v and "true" or "false"))
    end
  end
end

return M

