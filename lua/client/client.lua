require("client.client_functions")
require("common.common_functions")

-- We don't want to start. Send the args to the server instance instead.
local args = vim.call("argv")

local arg_str = ""
for index, iter in pairs(args) do
    iter = get_absolute_filepath(iter)

    -- Double quotes need to be escaped by the Neovim server session
    -- executing the command as well as the shell. Lua itself needs escaped
    -- backslashes too, so even more backslashes here...
    iter = string.gsub(iter, "\"", "\\\\\"")

    if (string.len(arg_str) == 0) then
        arg_str = iter
    else
        arg_str = arg_str.." "..iter
    end
end

-- Listen to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", existing_server_pipe_path, {rpc = true})

local cmd_to_execute = build_command(arg_str, #args, existing_server_pipe_path)

vim.fn.rpcnotify(sock, "nvim_exec_lua", "vim.cmd(\""..cmd_to_execute.."\")", {})

if (not vim.g.unception_block_while_host_edits) then
    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.fn.chanclose(sock)
    vim.cmd("quit")
end

-- Start up a pipe so that it can listen for a response from the host session.
local nested_pipe_path = vim.call("serverstart")

-- TODO: Can't get this working...
--if (#args ~= 1) then
--    local err_cmd = "vim.api.nvim_err_writeln('Only 1 argument is supported when g:unception_block_while_host_edits is true. Received '..#args..'.')"
--    vim.fn.rpcnotify(sock, "nvim_exec_lua", err_cmd, {})
--    vim.fn.chanclose(sock)
--    vim.cmd("quit")
--end

-- Send the pipe path and edited filepath to the host so that it knows what file to look for and who to respond to.
vim.fn.rpcnotify(sock, "nvim_exec_lua", "unception_notify_when_done_editing("..vim.inspect(nested_pipe_path)..","..vim.inspect(arg_str)..")", {})

-- Sleep forever. The host session will kill this when it's done editing.
while (true)
do
    vim.cmd("sleep 10")
end

