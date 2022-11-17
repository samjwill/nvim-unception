require("server.server_functions")

local new_server_pipe_path = vim.call("serverstart")
vim.call("setenv", pipe_path_host_env_var, new_server_pipe_path)

