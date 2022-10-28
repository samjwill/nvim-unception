local function get_absolute_filepath(relative_path)
    -- Surround with quotes in case of special chars before passing to
    -- realpath cmd. Also need to escape any existing double quotes.
    relative_path = string.gsub(relative_path, "\"", "\\\"")
    relative_path = "\""..relative_path.."\""

    local handle = io.popen("realpath "..relative_path)
    local absolute_path = handle:read("*a")
    handle:close()
    absolute_path = string.gsub(absolute_path, "\n", "")

    -- The absolute path that's returned needs escaped special chars.
    -- Just escaping everything once is acceptable, so go ahead and
    -- interpolate backslashes so we don't have to maintain a special
    -- character list or rely on another external tool.
    absolute_path = string.gsub(absolute_path, ".", "\\%1")

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

    -- Can't allow buffer holding terminal to be deleted. Easiest to just force
    -- a new tab to be used.
    if vim.g.unception_block_while_editing then
        vim.g.unception_open_buffer_in_new_tab = true
    end

    if vim.g.unception_open_buffer_in_new_tab then
        cmd_to_execute = cmd_to_execute.."silent tabnew | "
    end

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

    -- We don't want to delete the replaced buffer if there wasn't a replaced buffer vvv
    if (vim.g.unception_delete_replaced_buffer and not vim.g.unception_open_buffer_in_new_tab) then
        -- Only delete the terminal buffer if it's not visible in some other window.
        cmd_to_execute = cmd_to_execute.."if (len(win_findbuf(g:unception_tmp_bufnr)) == 0) | "
        cmd_to_execute = cmd_to_execute.."silent execute 'bdelete! ' . g:unception_tmp_bufnr | "
        cmd_to_execute = cmd_to_execute.."endif | "
    end

    -- remove temporary variable
    cmd_to_execute = cmd_to_execute.."silent unlet g:unception_tmp_bufnr | "

    -- remove command from history and enter it
    cmd_to_execute = cmd_to_execute.."call histdel(':', -1)<CR>"

    if (vim.g.unception_enable_flavor_text) then
        -- flavor text :)
        cmd_to_execute = cmd_to_execute..":echo 'Unception prevented inception!' | call histdel(':', -1)<CR>"
    end

    -- end command to be run by server
    cmd_to_execute = cmd_to_execute.."\""

    return cmd_to_execute
end



local existing_server_pipe_path = os.getenv("NVIM_UNCEPTION_PIPE_PATH")
local in_terminal_buffer = (existing_server_pipe_path ~= nil)

if not in_terminal_buffer then
    local new_server_pipe_path = vim.call("serverstart")
    vim.call("setenv", "NVIM_UNCEPTION_PIPE_PATH", new_server_pipe_path)
else
    -- We don't want to start. Send the args to the server instance instead.
    local args = vim.call("argv")

    local arg_str = ""
    for index, iter in pairs(args) do
        iter = get_absolute_filepath(iter)

        -- Double quotes need to be escaped by the Neovim server session
        -- executing the command as well as the shell. Lua itself needs escaped
        -- backslashes too, so even more backslashes here...
        iter = string.gsub(iter, "\"", "\\\\\"")

        arg_str = arg_str.." "..iter
    end

    local cmd_to_execute = build_command(arg_str, #args, existing_server_pipe_path)

    os.execute(cmd_to_execute)

    if (vim.g.unception_block_while_editing) then
        local socket = vim.fn.sockconnect("pipe", existing_server_pipe_path, {'rpc':1})
        vim.fn.rpcrequest(socket, "nvim_eval", "getpid()")
    end

    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.cmd("quit")
end

