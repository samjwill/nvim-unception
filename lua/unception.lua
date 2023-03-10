unception_pipe_path_host_env_var = "NVIM_UNCEPTION_PIPE_PATH_HOST"
local in_terminal_buffer = (os.getenv(unception_pipe_path_host_env_var) ~= nil)

if in_terminal_buffer then
    require("client.client")
else
    require("server.server")
end

