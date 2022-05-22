if not (vim.g.disable_unception == nil) then
    if vim.g.disable_unception > 0 then
        return
    end
end

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

    local execute_command = "\\nvim --server "..expected_pipe_name.." --remote-send "

    -- exit terminal-insert mode
    execute_command = execute_command.."\"<C-\\><C-N>"

    -- log buffer number so that we can delete it later. We don't want a ton of
    -- running terminal buffers in the background when we switch to a new nvim buffer.
    execute_command = execute_command..":silent let g:unception_tmp_bufnr = bufnr() | "

    -- If there aren't arguments, we just want a new, empty buffer, but if
    -- there are, append them to the host Neovim session's arguments list.
    if (#args > 0) then
        execute_command = execute_command.."silent argedit "..arg_str.." | "
    else
        execute_command = execute_command.."silent enew | "
    end

    -- remove the old terminal buffer
    execute_command = execute_command.."silent execute 'bdelete! ' . g:unception_tmp_bufnr | "

    -- remove temporary variable
    execute_command = execute_command.."silent unlet g:unception_tmp_bufnr<CR>"

    -- flavor text :)
    execute_command = execute_command..":echo 'Unception!'<CR>\""

    os.execute(execute_command)
    vim.cmd("quit")
else
    vim.call("serverstart", expected_pipe_name)
end

