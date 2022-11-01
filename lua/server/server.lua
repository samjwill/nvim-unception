require("server.server_callback")

local new_server_pipe_path = vim.call("serverstart")
vim.call("setenv", "NVIM_UNCEPTION_PIPE_PATH_HOST", new_server_pipe_path)

