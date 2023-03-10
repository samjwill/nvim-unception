require("common.common_functions")

local response_sock = nil
local unception_quitpre_autocmd_id = nil
local unception_bufunload_autocmd_id = nil
local filepath_to_check = nil
local blocked_terminal_buffer_id = nil
local last_replaced_buffer_id = nil

local function unblock_client_and_reset_state()
    -- Remove the autocmds we made.
    vim.api.nvim_del_autocmd(unception_quitpre_autocmd_id)
    vim.api.nvim_del_autocmd(unception_bufunload_autocmd_id)

    -- Unblock client by killing its editor session.
    vim.fn.rpcnotify(response_sock, "nvim_exec_lua", "vim.cmd('quit')", {})
    vim.fn.chanclose(response_sock)

    -- Reset state-sensitive variables.
    response_sock = nil
    unception_quitpre_autocmd_id = nil
    unception_bufunload_autocmd_id = nil
    filepath_to_check = nil
    blocked_terminal_buffer_id = nil
    last_replaced_buffer_id = nil
end

function _G.unception_handle_bufunload(unloaded_buffer_filepath)
    unloaded_buffer_filepath = unception_get_absolute_filepath(unloaded_buffer_filepath)
    unloaded_buffer_filepath = unception_escape_special_chars(unloaded_buffer_filepath)

    if (unloaded_buffer_filepath == filepath_to_check) then
        unblock_client_and_reset_state()
    end
end

function _G.unception_handle_quitpre(quitpre_buffer_filepath)
    quitpre_buffer_filepath = unception_get_absolute_filepath(quitpre_buffer_filepath)
    quitpre_buffer_filepath = unception_escape_special_chars(quitpre_buffer_filepath)

    if (quitpre_buffer_filepath == filepath_to_check) then
        -- If this buffer replaced the blocked terminal buffer, we should restore it to the same window.
        if (blocked_terminal_buffer_id ~= nil and vim.fn.bufexists(blocked_terminal_buffer_id) == 1) then
            vim.cmd("split") -- Open a new window and switch focus to it.
            vim.cmd("buffer " .. blocked_terminal_buffer_id) -- Set the buffer for that window to the buffer that was replaced.
            vim.cmd("wincmd x") -- Navigate to previous (initial) window, and proceed with quitting.
        end

        unblock_client_and_reset_state()
    end
end

function _G.unception_notify_when_done_editing(pipe_to_respond_on, filepath)
    filepath_to_check = filepath
    blocked_terminal_buffer_id = last_replaced_buffer_id
    response_sock = vim.fn.sockconnect("pipe", pipe_to_respond_on, {rpc = true})
    unception_quitpre_autocmd_id = vim.api.nvim_create_autocmd("QuitPre",{ command = "lua unception_handle_quitpre(vim.fn.expand('<afile>:p'))"})

    -- Create an autocmd for BufUnload as a failsafe should QuitPre not get triggered on the target buffer (e.g. if a user runs :bdelete).
    unception_bufunload_autocmd_id = vim.api.nvim_create_autocmd("BufUnload",{ command = "lua unception_handle_bufunload(vim.fn.expand('<afile>:p'))"})
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
            last_replaced_buffer_id = nil
            vim.cmd("tab argument 1")
        else
            last_replaced_buffer_id = vim.fn.bufnr()
            vim.cmd("argument 1")
        end

        -- This is kind of stupid, but basically, it appears that Neovim may
        -- not always properly handle opening buffers using the method
        -- above(?), notably if it's opening directly to a directory using
        -- netrw. Calling "edit" here appears to give it another chance to
        -- properly handle opening the buffer; otherwise it can occasionally
        -- segfault.
        vim.cmd("edit")
    else
        if (open_in_new_tab) then
            last_replaced_buffer_id = nil
            vim.cmd("tabnew")
        else
            last_replaced_buffer_id = vim.fn.bufnr()
            vim.cmd("enew")
        end
    end

    -- We don't want to delete the replaced buffer if there wasn't a replaced buffer.
    if (delete_replaced_buffer and last_replaced_buffer_id ~= nil) then
        if (vim.fn.len(vim.fn.win_findbuf(tmp_buf_number)) == 0 and string.sub(vim.api.nvim_buf_get_name(0), 1, 7) == "term://") then
            vim.cmd("bdelete! "..tmp_buf_number)
        end
    end

    if (enable_flavor_text) then
        print("Unception prevented inception!")
    end
end

