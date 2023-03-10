require("common.common_functions")

-- We don't want to start. Send the args to the server instance instead.
local args = vim.call("argv")

local arg_str = ""
for index, iter in pairs(args) do
    local absolute_filepath = unception_get_absolute_filepath(iter)

    if (string.len(arg_str) == 0) then
        arg_str = absolute_filepath
    else
        arg_str = arg_str.." "..absolute_filepath
    end
end

arg_str = unception_escape_special_chars(arg_str)

-- Send messages to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", os.getenv(unception_pipe_path_host_env_var), {rpc = true})
local edit_files_call = "unception_edit_files("
                       .."\""..arg_str.."\", "
                       ..#args..", "
                       ..vim.inspect(vim.g.unception_open_buffer_in_new_tab)..", "
                       ..vim.inspect(vim.g.unception_delete_replaced_buffer)..", "
                       ..vim.inspect(vim.g.unception_enable_flavor_text)..")"
vim.fn.rpcnotify(sock, "nvim_exec_lua", edit_files_call, {})

if (not vim.g.unception_block_while_host_edits) then
    -- Our work here is done. Kill the nvim session that would have started otherwise.
    vim.fn.chanclose(sock)

    if (not vim.g.unception_delete_replaced_buffer) then
        -- TODO: Try removing this conditional when Neovim core gets updated.
        -- "qall!" should always be called here, regardless of whether
        -- unception_delete_replaced_buffer is true.
        --
        -- See issue #60 in GitHub. Looks like there might be a bug in Neovim
        -- core that can ocassionally cause a segfault when deleting a terminal
        -- buffer? In any case, not exiting here appears to rectify the
        -- behavior, but it is a band-aid.
        vim.cmd("qall!")
    end

    return
end

-- Start up a pipe so that the client can listen for a response from the host session.
local nested_pipe_path = vim.call("serverstart")

-- Send the pipe path and edited filepath to the host so that it knows what file to look for and who to respond to.
local notify_when_done_call = "unception_notify_when_done_editing("
                              ..vim.inspect(nested_pipe_path)..","
                              ..vim.inspect(arg_str)..")"
vim.fn.rpcnotify(sock, "nvim_exec_lua", notify_when_done_call, {})

-- Sleep forever. The host session will kill this when it's done editing.
while (true)
do
    vim.cmd("sleep 10")
end

