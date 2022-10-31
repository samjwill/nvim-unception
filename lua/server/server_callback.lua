require("common.common_functions")

local response_sock
local unception_bufunload_autocmd_id
local filepath_to_check

function unception_handle_unloaded_buffer(unloaded_buffer_filepath)
    unloaded_buffer_filepath = get_absolute_filepath(unloaded_buffer_filepath)

    if (unloaded_buffer_filepath == filepath_to_check) then
        vim.api.nvim_del_autocmd(unception_bufunload_autocmd_id)
        vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('quit')", {})
        -- TODO: Find out if this is necessary.
        -- vim.fn.chanclose(response_sock)
    end
end

function _G.unception_notify_when_done_editing(pipe_to_respond_on, filepath)
    filepath_to_check = filepath
    response_sock = vim.fn.sockconnect("pipe", pipe_to_respond_on, {rpc = true})
    unception_bufunload_autocmd_id = vim.api.nvim_create_autocmd("BufUnload",{ command = "lua unception_handle_unloaded_buffer(vim.fn.expand('<afile>:p'))"})
end

