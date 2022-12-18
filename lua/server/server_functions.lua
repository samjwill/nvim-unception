require("common.common_functions")

local response_sock
local unception_bufunload_autocmd_id
local filepath_to_check
local id_of_replaced_buffer = nil

function unception_handle_unloaded_buffer(unloaded_buffer_filepath)
    unloaded_buffer_filepath = get_absolute_filepath(unloaded_buffer_filepath)
    unloaded_buffer_filepath = escape_special_chars(unloaded_buffer_filepath)

    if (unloaded_buffer_filepath == filepath_to_check) then
        -- If there was a replaced buffer, we should restore it to the same window.
        if (id_of_replaced_buffer ~= nil) then
            local winnr = vim.fn.winnr()
            vim.cmd("split") -- Open a new window and switch focus to it
            vim.cmd("buffer " .. id_of_replaced_buffer) -- Set the buffer for that window to the buffer that was replaced.
            vim.cmd("wincmd x") -- Navigate to previous (initial) window, and proceed with quitting.
            id_of_replaced_buffer = nil
        end

        vim.api.nvim_del_autocmd(unception_bufunload_autocmd_id)
        vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('quit')", {})
        vim.fn.chanclose(response_sock)
    end
end

function _G.unception_notify_when_done_editing(pipe_to_respond_on, filepath)
    filepath_to_check = filepath
    response_sock = vim.fn.sockconnect("pipe", pipe_to_respond_on, {rpc = true})
    unception_bufunload_autocmd_id = vim.api.nvim_create_autocmd("QuitPre",{ command = "lua unception_handle_unloaded_buffer(vim.fn.expand('<afile>:p'))"})
end

function _G.unception_edit_files(file_args, num_files_in_list, open_in_new_tab, delete_replaced_buffer, enable_flavor_text)
    vim.api.nvim_exec_autocmds("User", {pattern = "UnceptionEditRequestReceived"})

    -- log buffer number so that we can delete it later. We don't want a ton of
    -- running terminal buffers in the background when we switch to a new nvim buffer.
    local tmp_buf_number = vim.fn.bufnr()

    -- If there aren't arguments, we just want a new, empty buffer, but if
    -- there are, append them to the host Neovim session's arguments list.
    if (num_files_in_list > 0) then
        -- Had some issues when using argedit. Explicitly calling these
        -- separately appears to work though.
        vim.cmd("0argadd "..file_args)

        if (open_in_new_tab) then
            vim.cmd("tab argument 1")
        else
            id_of_replaced_buffer = vim.fn.bufnr()
            vim.cmd("argument 1")
        end

        -- This is kind of stupid, but basically, I've noticed that some
        -- plugins, like Treesitter, don't appear to properly trigger when
        -- receiving a command that executes argedit. I just re-edit the same
        -- file here to give stuff like Treesitter's syntax highlighting
        -- another chance to trigger, since doing so doesn't hurt anything.
        -- Sometimes it works.
        vim.cmd("edit")
    else
        if (open_in_new_tab) then
            vim.cmd("tabnew")
        else
            id_of_replaced_buffer = vim.fn.bufnr()
            vim.cmd("enew")
        end
    end

    -- We don't want to delete the replaced buffer if there wasn't a replaced buffer
    if (delete_replaced_buffer and not open_in_new_tab) then
        if (vim.fn.len(vim.fn.win_findbuf(tmp_buf_number)) == 0) then
            pcall(vim.cmd, "bdelete! "..tmp_buf_number) -- Use pcall so it doesn't complain if it fails to delete the buffer.
        end
    end

    if (enable_flavor_text) then
        print("Unception prevented inception!")
    end
end

