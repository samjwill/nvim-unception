if(vim.g.unception_delete_replaced_buffer == nil) then
    vim.g.unception_delete_replaced_buffer = false
end

if(vim.g.unception_open_buffer_in_new_tab == nil) then
    vim.g.unception_open_buffer_in_new_tab = false
end

if (vim.g.unception_disable == nil) then
    vim.g.unception_disable = false
end

if (vim.g.unception_enable_flavor_text == nil) then
    vim.g.unception_enable_flavor_text = true
end

if (vim.g.unception_block_while_editing == nil) then
    vim.g.unception_block_while_editing = false
end

-- Can't allow buffer holding terminal to be deleted. Also don't want the
-- terminal buffer to get hidden, so open the buffer being edited in a new tab.
if (vim.g.unception_block_while_editing) then
    vim.g.unception_open_buffer_in_new_tab = true
    vim.g.unception_delete_replaced_buffer = false
end

