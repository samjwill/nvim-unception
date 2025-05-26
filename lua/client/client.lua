require("common.common_functions")
require("common.arg_parse")

-- We don't want to overwrite :h shada
vim.o.sdf = "NONE"

-- We don't want to start. Send the args to the server instance instead.
-- get only files argument already parsed by neovim
local true_file_args = vim.call("argv")
local options = {
    open_in_new_tab = vim.g.unception_open_buffer_in_new_tab,
    delete_replaced_buffer = vim.g.unception_delete_replaced_buffer,
    enable_flavor_text = vim.g.unception_enable_flavor_text,
    multi_file_open_method = vim.g.unception_multi_file_open_method,
}
-- Use raw argv to retreive some options as well as files lines when it exist
local file_lines = unception_arg_parse(vim.v.argv, options)
local file_args = {}
for _, file in ipairs(true_file_args) do
    local absolute_filepath = unception_get_absolute_filepath(file)
    table.insert(file_args , {
        path = unception_escape_special_chars(absolute_filepath),
        line = file_lines[file]
    })
end

-- Send messages to host on existing pipe.
local sock = vim.fn.sockconnect("pipe", os.getenv(unception_pipe_path_host_env_var), { rpc = true })
vim.rpcrequest(sock, "nvim_exec_lua", "unception_edit_files(...)", { file_args, options })

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
vim.rpcnotify(sock, "nvim_exec_lua", "unception_notify_when_done_editing(...)", { nested_pipe_path, file_args[1].path })

-- Sleep forever. The host session will kill this when it's done editing.
while (true)
do
    vim.cmd("sleep 10")
end
