require("client_functions")

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

local cmd_to_execute = build_command(arg_str, #args, existing_server_pipe_path)

--TODO: Uncomment!
--os.execute(cmd_to_execute)

if (vim.g.unception_block_while_editing) then
    sock = vim.fn.sockconnect("pipe", existing_server_pipe_path, {rpc = true})
    print(vim.fn.rpcrequest(sock, "nvim_exec_lua", "return tmp_unception_still_being_edited("..vim.inspect(arg_str)..")", {}))

    while (true)
    do
        vim.cmd("sleep 10")
    end
end

-- Our work here is done. Kill the nvim session that would have started otherwise.
--TODO: Uncomment!
--vim.cmd("quit")
