existing_server_pipe_path = os.getenv("NVIM_UNCEPTION_PIPE_PATH_HOST")
in_terminal_buffer = (existing_server_pipe_path ~= nil)

if in_terminal_buffer then
    require("client.client")
else
    require("server.server")
end

