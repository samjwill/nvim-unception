local in_terminal_buffer = (os.getenv("NVIM") ~= nil)

if in_terminal_buffer then
    require("client.client")
else
    require("server.server")
end

