let my_socket = sockconnect("pipe", "/tmp/nvim.user/OjfIs/nvim.3552.1", {'rpc':1})
echo rpcrequest(my_socket, "nvim_eval", "getpid()")

-- Idea: if g:nvim_unception_block_while_editing is set to true, will build the
-- usual --remote command (with the exception that it will force the buffer to
-- be opened in a new tab), but before exiting, send an rpcrequest() to the
-- server session. The socket can be retrieved by calling socketconnect on the
-- named pipe.
--
-- The request will contain the full path of the file being edited as a
-- parameter. Once the request is received, the server will execute a
-- predefined function `block_while_editing(filepath)`, and an autocmd will be
-- set up such that it will stay blocked until the git commit buffer is
-- unloaded, in which case the function will return.
