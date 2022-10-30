existing_server_pipe_path = os.getenv("NVIM_UNCEPTION_PIPE_PATH_HOST")
in_terminal_buffer = (existing_server_pipe_path ~= nil)

if not in_terminal_buffer then
    require("server")
else
    require("client")
end

