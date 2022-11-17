pipe_path_host_env_var = "NVIM_UNCEPTION_PIPE_PATH_HOST"
existing_server_pipe_path = os.getenv(pipe_path_host_env_var)
local in_terminal_buffer = (existing_server_pipe_path ~= nil)

if in_terminal_buffer then
    require("client.client")
else
    require("server.server")
end

