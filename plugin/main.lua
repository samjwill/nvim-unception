require("init_default_settings_vars")

if (vim.g.unception_disable) then
    return
end

if (1 ~= vim.fn.has("nvim-0.7.0")) then
    vim.api.nvim_err_writeln "Unception requires Neovim 0.7 or later."
    return
end

require("unception")

