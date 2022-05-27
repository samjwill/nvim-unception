if not (vim.g.disable_unception == nil) then
    if vim.g.disable_unception > 0 then
        return
    end
end

if 1 ~= vim.fn.has "nvim-0.7.0" then
    vim.api.nvim_err_writeln "Unception requires Neovim 0.7 or higher."
    return
end

local function nvim_already_running(filename)
    local handle = io.popen("pidof nvim")
    nvim_pid_str = handle:read("*a")
    handle:close()

    --If there's a space, then at least two instances are running.
    _, num_spaces = string.gsub(nvim_pid_str, " ", " ")
    return (num_spaces > 0)
end

local function build_command(arg_str, number_of_args, server_address)
    local cmd_to_execute = "\\nvim --server "..server_address.." --remote-send "

    -- start command to be run by server
    cmd_to_execute = cmd_to_execute.."\""

    -- exit terminal-insert mode
    cmd_to_execute = cmd_to_execute.."<C-\\><C-N>"

    -- log buffer number so that we can delete it later. We don't want a ton of
    -- running terminal buffers in the background when we switch to a new nvim buffer.
    cmd_to_execute = cmd_to_execute..":silent let g:unception_tmp_bufnr = bufnr() | "

    -- If there aren't arguments, we just want a new, empty buffer, but if
    -- there are, append them to the host Neovim session's arguments list.
    if (number_of_args > 0) then
        cmd_to_execute = cmd_to_execute.."silent argedit "..arg_str.." | "
    else
        cmd_to_execute = cmd_to_execute.."silent enew | "
    end

    -- remove the old terminal buffer
    cmd_to_execute = cmd_to_execute.."silent execute 'bdelete! ' . g:unception_tmp_bufnr | "

    -- remove temporary variable
    cmd_to_execute = cmd_to_execute.."silent unlet g:unception_tmp_bufnr | "

    -- remove command from history and send it
    cmd_to_execute = cmd_to_execute.."call histdel(':', -1)<CR>"

    -- flavor text :)
    cmd_to_execute = cmd_to_execute..":echo 'Unception prevented inception!' | call histdel(':', -1)<CR>\""

    return cmd_to_execute
end

local username = os.getenv("USER")
local expected_pipe_name = "/tmp/nvim-"..username..".pipe"
--TODO use tmpdir environment variable
--TODO: Checking if the pipe exists probably isn't sufficient. Should instead
--check if the pipe is currently attached to a Neovim session.
if not nvim_already_running() then
    args = vim.call("argv")

    local arg_str = ""
    for index, iter in pairs(args) do
        local handle = io.popen("realpath "..iter)
        iter = handle:read("*a")
        handle:close()
        iter = string.gsub(iter, "\n", "")
        arg_str = arg_str.." "..iter
    end

    local cmd_to_execute = build_command(arg_str, #args, expected_pipe_name)

    os.execute(cmd_to_execute)

    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.cmd("quit")
else
    vim.call("serverstart", expected_pipe_name)
end

