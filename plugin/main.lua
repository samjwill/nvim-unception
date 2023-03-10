-------------------------------------------------------------------------------
-- Initialize all expected variables
-------------------------------------------------------------------------------
if(vim.g.unception_delete_replaced_buffer == nil) then
    vim.g.unception_delete_replaced_buffer = false
end

if(vim.g.unception_open_buffer_in_new_tab == nil) then
    vim.g.unception_open_buffer_in_new_tab = false
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

if (vim.g.unception_disable  == nil) then
    vim.g.unception_disable = false
end

-- If in ":h --headless" or ":h --embed" mode, a UI is not desired, so don't
-- run the plugin.
if (0 == #vim.api.nvim_list_uis()) then
    vim.g.unception_disable = true
end

-- Version check to ensure that necessary features are available.
if (1 ~= vim.fn.has("nvim-0.7.0")) then
    vim.api.nvim_err_writeln("Unception requires Neovim 0.7 or later.")
    vim.g.unception_disable = true
end

if (vim.g.unception_block_while_host_edits and #(vim.call("argv")) ~= 1) then
    vim.api.nvim_err_writeln("Must have exactly 1 argument when g:unception_block_while_host_edits is enabled!")
    vim.g.unception_disable = true
end

-------------------------------------------------------------------------------
-- Handle early exit if necessary
-------------------------------------------------------------------------------
if (vim.g.unception_disable) then
    return
end

-------------------------------------------------------------------------------
-- We're good to go. Start the main plugin logic.
-------------------------------------------------------------------------------
require("unception")

