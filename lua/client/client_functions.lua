function build_command(arg_str, number_of_args, server_address)
    -- log buffer number so that we can delete it later. We don't want a ton of
    -- running terminal buffers in the background when we switch to a new nvim buffer.
    cmd_to_execute = "silent let g:unception_tmp_bufnr = bufnr() | "

    if vim.g.unception_open_buffer_in_new_tab then
        cmd_to_execute = cmd_to_execute.."silent tabnew | "
    end

    -- If there aren't arguments, we just want a new, empty buffer, but if
    -- there are, append them to the host Neovim session's arguments list.
    if (number_of_args > 0) then
        -- Had some issues when using argedit. Explicitly calling these
        -- separately appears to work though.
        cmd_to_execute = cmd_to_execute.."silent 0argadd "..arg_str.." | "
        cmd_to_execute = cmd_to_execute.."silent argument 1 | "

        -- This is kind of stupid, but basically, I've noticed that some
        -- plugins, like Treesitter, don't appear to properly trigger when
        -- receiving a server command with argedit. I just re-edit the
        -- same file here to give stuff like Treesitter's syntax
        -- highlighting another chance to trigger, since doing so doesn't
        -- hurt anything. Sometimes it works.
        cmd_to_execute = cmd_to_execute.."silent e | "
    else
        cmd_to_execute = cmd_to_execute.."silent enew | "
    end

    -- We don't want to delete the replaced buffer if there wasn't a replaced buffer vvv
    if (vim.g.unception_delete_replaced_buffer and not vim.g.unception_open_buffer_in_new_tab) then
        -- Only delete the terminal buffer if it's not visible in some other window.
        cmd_to_execute = cmd_to_execute.."if (len(win_findbuf(g:unception_tmp_bufnr)) == 0) | "
        cmd_to_execute = cmd_to_execute.."silent execute 'bdelete! ' . g:unception_tmp_bufnr | "
        cmd_to_execute = cmd_to_execute.."endif | "
    end

    -- remove temporary variable
    cmd_to_execute = cmd_to_execute.."silent unlet g:unception_tmp_bufnr | "

    -- remove command from history and enter it
    cmd_to_execute = cmd_to_execute.."call histdel(':', -1)"

    if (vim.g.unception_enable_flavor_text) then
        cmd_to_execute = cmd_to_execute.." | echo 'Unception prevented inception!' | call histdel(':', -1)"
    end

    return cmd_to_execute
end

