if not (vim.g.disable_unception == nil) then
    if vim.g.disable_unception > 0 then
        return
    end
end

if 1 ~= vim.fn.has "nvim-0.7.0" then
    vim.api.nvim_err_writeln "Unception requires Neovim 0.7 or higher."
    return
end

local function get_absolute_filepath(relative_path)
    local handle = io.popen("realpath "..relative_path)
    absolute_path = handle:read("*a")
    handle:close()
    absolute_path = string.gsub(absolute_path, "\n", "")
    return absolute_path
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
        -- Had some issues when using argedit. Explicitly calling these
        -- separately appears to work though.
        cmd_to_execute = cmd_to_execute.."silent 0argadd "..arg_str.." | "
        cmd_to_execute = cmd_to_execute.."silent argument 1 | "

        -- This is kind of stupid, but basically, I've noticed that some
        -- plugins, like Treesitter, don't appear to properly trigger when
        -- receiving a server command with argedit. I just re-edit the
        -- same file here to give stuff like Treesitter's syntax
        -- highlighting another chance to trigger, since doing so doesn't
        -- hurt anything. Sometimes it works.
        cmd_to_execute = cmd_to_execute.."silent e | "
    else
        cmd_to_execute = cmd_to_execute.."silent enew | "
    end

    -- remove the old terminal buffer
    cmd_to_execute = cmd_to_execute.."silent execute 'bdelete! ' . g:unception_tmp_bufnr | "

    -- remove temporary variable
    cmd_to_execute = cmd_to_execute.."silent unlet g:unception_tmp_bufnr | "

    -- remove command from history and enter it
    cmd_to_execute = cmd_to_execute.."call histdel(':', -1)<CR>"

    -- flavor text :)
    cmd_to_execute = cmd_to_execute..":echo 'Unception prevented inception!' | call histdel(':', -1)<CR>\""

    return cmd_to_execute
end

local username = os.getenv("USER")
local server_pipe_path = os.getenv("NVIM_UNCEPTION_PIPE_PATH")

local in_terminal_buffer = (server_pipe_path ~= nil)
if not in_terminal_buffer then
    -- TODO: Ensure file doesn't exist first, and make unique.
    server_pipe_path = "/tmp/nvim-unception-"..username..".pipe"

    -- Clean up if the pipe still exists for whatever reason.
    os.execute("rm -f "..server_pipe_path)
    vim.call("serverstart", server_pipe_path)
    vim.call("setenv", 'NVIM_UNCEPTION_PIPE_PATH', server_pipe_path)
else
    -- We don't want to start. Send the args to the server instance instead.
    args = vim.call("argv")

    local arg_str = ""
    for index, iter in pairs(args) do
        iter = get_absolute_filepath(iter)
        arg_str = arg_str.." "..iter
    end

    local cmd_to_execute = build_command(arg_str, #args, server_pipe_path)

    os.execute(cmd_to_execute)

    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.cmd("quit")
end

