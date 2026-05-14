unception_pipe_path_host_env_var = "NVIM_UNCEPTION_PIPE_PATH_HOST"

local function host_pipe_is_usable(pipe_path)
    if not pipe_path or pipe_path == "" then
        return false
    end

    local ok, chan = pcall(vim.fn.sockconnect, "pipe", pipe_path, { rpc = true })
    if not ok or type(chan) ~= "number" or chan <= 0 then
        return false
    end

    vim.fn.chanclose(chan)
    return true
end

local in_terminal_buffer = host_pipe_is_usable(os.getenv(unception_pipe_path_host_env_var))

if in_terminal_buffer then
    require("client.client")
else
    require("server.server")
end
