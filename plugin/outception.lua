local function exists(filename)
   local ok, message, err_code = os.rename(filename, filename)
   if not ok then
      if err_code == 13 then
         --file couldn't be renamed, but was found
         ok = true
      end
   end
   return ok
end

local username = os.getenv("USER")
local expected_pipe_name = "/tmp/nvim-"..username..".pipe"

if exists(expected_pipe_name) then
    args = vim.call("argv")

    local arg_str = ""
    for index, iter in pairs(args) do
        arg_str = arg_str.." "..iter
    end

    if (#args > 0) then
        os.execute("\\nvim --server "..expected_pipe_name.." --remote-send \"<C-\\><C-N>:argedit "..arg_str.."<CR>\"")
    else
        os.execute("\\nvim --server "..expected_pipe_name.." --remote-send \"<C-\\><C-N>:enew<CR>\"")
    end
    vim.cmd("quit")
else
    vim.call("serverstart", expected_pipe_name)
end
