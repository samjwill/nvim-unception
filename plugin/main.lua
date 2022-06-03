require("init_config_defaults")

if (vim.g.unception_disable) then
    return
end

if 1 ~= vim.fn.has "nvim-0.7.0" then
    vim.api.nvim_err_writeln "Unception requires Neovim 0.7 or higher."
    return
end

require("unception")

