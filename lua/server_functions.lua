local response_sock -- TODO: Unsure if I actually have to declare it here.
local unception_bufunload_autocmd_id

function _G.tmp_unception_still_being_edited(pipe_to_respond_on, filepath)
    filepath_to_check = filepath
    response_sock = vim.fn.sockconnect("pipe", pipe_to_respond_on, {rpc = true})
    unception_bufunload_autocmd_id = vim.api.nvim_create_autocmd("BufUnload",{ command = "lua handle_unloaded_buffer(vim.fn.expand('<afile>:p'))"})
    return filepath_to_check
end

-- TODO: Global necessary?
function _G.handle_unloaded_buffer(unloaded_buffer_filepath)
    unloaded_buffer_filepath = get_absolute_filepath(unloaded_buffer_filepath)

    if (unloaded_buffer_filepath == filepath_to_check) then
        vim.api.nvim_del_autocmd(unception_bufunload_autocmd_id)
        vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('quit')", {})
    end
end

