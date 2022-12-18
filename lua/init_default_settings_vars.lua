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

if (vim.g.unception_block_while_host_edits == nil) then
    vim.g.unception_block_while_host_edits = false
end

-- Can't allow buffer holding terminal to be deleted.
if (vim.g.unception_block_while_host_edits) then
    vim.g.unception_delete_replaced_buffer = false
end

