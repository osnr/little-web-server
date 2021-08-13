local ffi = require 'ffi'
ffi.cdef[[
int socket(int domain, int type, int protocol);
]]

local listenfd = ffi.C.socket(AF_INET, SOCK_STREAM, 0)
