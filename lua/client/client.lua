require("common.common_functions")

-- We don't want to start. Send the args to the server instance instead.
local args = vim.call("argv")

local arg_str = ""
for index, iter in pairs(args) do
    local absolute_filepath = get_absolute_filepath(iter)

    if (string.len(arg_str) == 0) then
        arg_str = absolute_filepath
    else
        arg_str = arg_str.." "..absolute_filepath
    end
end

arg_str = escape_special_chars(arg_str)

-- Send messages to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", existing_server_pipe_path, {rpc = true})
vim.fn.rpcnotify(sock, "nvim_exec_lua", "unception_edit_files("
                                        .."\""..arg_str.."\""
                                        ..", "
                                        ..#args
                                        ..", "
                                        ..vim.inspect(vim.g.unception_open_buffer_in_new_tab)
                                        ..", "
                                        ..vim.inspect(vim.g.unception_delete_replaced_buffer)
                                        ..", "
                                        ..vim.inspect(vim.g.unception_enable_flavor_text)
                                        ..")"
                                        ,{})

if (not vim.g.unception_block_while_host_edits) then
    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.fn.chanclose(sock)
    vim.cmd("quit")
    return
end

-- Start up a pipe so that client can listen for a response from the host session.
local nested_pipe_path = vim.call("serverstart")

if (#args ~= 1) then
    local err = "Must have exactly 1 argument when g:unception_block_while_host_edits is enabled!"
    vim.fn.rpcrequest(sock, "nvim_exec_lua", "vim.api.nvim_err_writeln('"..err.."')", {})
    vim.fn.chanclose(sock)
    vim.cmd("quit!")
    return
end

-- Send the pipe path and edited filepath to the host so that it knows what file to look for and who to respond to.
vim.fn.rpcnotify(sock, "nvim_exec_lua", "unception_notify_when_done_editing("
                                        ..vim.inspect(nested_pipe_path)
                                        ..","
                                        ..vim.inspect(arg_str)
                                        ..")"
                                        ,{})

-- Sleep forever. The host session will kill this when it's done editing.
while (true)
do
    vim.cmd("sleep 10")
end

