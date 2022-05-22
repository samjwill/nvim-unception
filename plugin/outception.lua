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

--TODO: Checking if the pipe exists probably isn't sufficient. Should instead
--check if the pipe is currently attached to a Neovim session.
if exists(expected_pipe_name) then
    args = vim.call("argv")

    local arg_str = ""
    for index, iter in pairs(args) do
        local handle = io.popen("realpath "..iter)
        iter = handle:read("*a")
        handle:close()
        iter = string.gsub(iter, "\n", "")
        arg_str = arg_str.." "..iter
    end

    if (#args > 0) then
        os.execute("\\nvim --server "..expected_pipe_name.." --remote-send \"<C-\\><C-N>:silent argedit "..arg_str.."<CR>\"")
        --:let g:outception_tmp_bufname = bufnr()
        --TODO: execute "bdelete " . g:outception_tmp_bufname
    else
        os.execute("\\nvim --server "..expected_pipe_name.." --remote-send \"<C-\\><C-N>:silent enew<CR>\"")
    end
    vim.cmd("quit")
else
    vim.call("serverstart", expected_pipe_name)
end
