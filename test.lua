let my_socket = sockconnect("pipe", "/tmp/nvim.user/OjfIs/nvim.3552.1", {'rpc':1})
echo rpcrequest(my_socket, "nvim_eval", "getpid()")
