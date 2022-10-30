require("server_functions")
require("common_functions")

local new_server_pipe_path = vim.call("serverstart")
vim.call("setenv", "NVIM_UNCEPTION_PIPE_PATH_HOST", new_server_pipe_path)

