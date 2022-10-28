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
--
-- ISSUE: We only want to block on the side of the client making the request.
-- We do not want to block serverside. Ergo, this needs thought out some more,
-- as the RPC functions are executed synchronously instead of asynchronously.
--
-- Updated idea: Have client open file normally, and then loop every .5 seconds
-- asking host session if currently editing the .gitcommit file. Server returns
-- true or false. Note: will need to test initial --remote function to ensure
-- that it is syncronous; we need to ensure that host neovim actually has time
-- to open the git commit file.
--
-- https://github.com/neovim/neovim/blob/0c537240df9ceaa9f9019d24d6d4dddea7744387/runtime/lua/vim/_editor.lua#L699-L706
