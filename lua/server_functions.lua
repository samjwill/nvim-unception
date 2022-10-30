function _G.tmp_unception_still_being_edited(filepath)
    filepath_to_check = filepath
    vim.api.nvim_create_autocmd("BufUnload",{ command = "lua handle_unloaded_buffer(vim.fn.expand('<afile>:p'))"})
    return filepath_to_check
end

-- TODO: Global necessary?
function _G.handle_unloaded_buffer(unloaded_buffer_filepath)
    unloaded_buffer_filepath = get_absolute_filepath(unloaded_buffer_filepath)

    if (unloaded_buffer_filepath == filepath_to_check) then
        print("ITS A MATCH!")
        --TODO: Use rpcnotify instead?
        --TODO: send notify out to client that its buffer was unloaded and that it can stop blocking
        --TODO: delete the autocmd
    end

    print(unloaded_buffer_filepath)
    print(filepath_to_check)
end

