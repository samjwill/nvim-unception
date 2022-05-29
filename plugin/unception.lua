if not (vim.g.disable_unception == nil) then
    if vim.g.disable_unception > 0 then
        return
    end
end

if 1 ~= vim.fn.has "nvim-0.7.0" then
    vim.api.nvim_err_writeln "Unception requires Neovim 0.7 or higher."
    return
end

local function nvim_already_running()
    local handle = io.popen("pgrep nvim -u $USER")
    nvim_pid_str = handle:read("*a")
    handle:close()

    _, num_processes = string.gsub(nvim_pid_str, "%S+", "")
    return (num_processes > 1) -- Don't count yourself ;)
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
        cmd_to_execute = cmd_to_execute.."silent argadd "..arg_str.." | "
        cmd_to_execute = cmd_to_execute.."silent argument | "

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
local server_pipe_path = "/tmp/nvim-"..username..".pipe"

if nvim_already_running() then
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
else
    vim.call("serverstart", server_pipe_path)
end

