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

-- Send messages to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", existing_server_pipe_path, {rpc = true})

-- Need to escape backslashes and quotes in case they are part of the
-- filepaths. Lua needs \\ to define a \, so to escape special chars,
-- there are twice as many backslashes as you would think that there
-- should be.
if (arg_str ~= nil) then
	arg_str = string.gsub(arg_str, "\\", "\\\\\\\\")
	arg_str = string.gsub(arg_str, "\"", "\\\\\\\"")
else
	arg_str = ""
end

vim.fn.rpcnotify(sock, "nvim_exec_lua", "unception_edit_files(\""..arg_str.."\", "..#args..")", {})

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
	vim.fn.rpcrequest(sock, "nvim_exec_lua", "vim.api.nvim_err_writeln('Must have exactly 1 argument when g:unception_block_while_host_edits is enabled!')", {})
    vim.fn.chanclose(sock)
    vim.cmd("quit!")
    return
end

-- Send the pipe path and edited filepath to the host so that it knows what file to look for and who to respond to.
vim.fn.rpcnotify(sock, "nvim_exec_lua", "unception_notify_when_done_editing("
										..vim.inspect(nested_pipe_path)
										..","
										..vim.inspect(arg_str)
										..","
										..vim.inspect(vim.g.unception_open_buffer_in_new_tab)
										..","
										..vim.inspect(vim.g.unception_delete_replaced_buffer)
										..","
										..vim.inspect(vim.g.unception_enable_flavor_text)
										..")"
										,{})

-- Sleep forever. The host session will kill this when it's done editing.
while (true)
do
    vim.cmd("sleep 10")
end

