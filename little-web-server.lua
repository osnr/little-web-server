local ffi = require 'ffi'
ffi.cdef[[
int socket(int domain, int type, int protocol);
static const int AF_INET = 2; /* IP protocol family.  */
static const int SOCK_STREAM = 1; /* Sequenced, reliable, connection-based
		              byte streams.  */
typedef uint16_t in_port_t;
/* POSIX.1g specifies this type name for the `sa_family' member.  */
typedef unsigned short int sa_family_t;
/* Internet address. */
struct in_addr {
    uint32_t       s_addr;     /* address in network byte order */
};
struct sockaddr_in {
    sa_family_t    sin_family; /* address family: AF_INET */
    in_port_t      sin_port;   /* port in network byte order */
    struct in_addr sin_addr;   /* internet address */
};
uint16_t htons(uint16_t hostshort);
uint32_t htonl(uint32_t hostlong);
static const uint32_t INADDR_LOOPBACK = 0x7f000001;
]]

local socket = ffi.C.socket(ffi.C.AF_INET, ffi.C.SOCK_STREAM, 0)
local addr = ffi.new('struct sockaddr_in')
addr.sin_family = ffi.C.AF_INET
addr.sin_port = ffi.C.htons(8080)
addr.sin_addr.s_addr = ffi.C.htonl(ffi.C.INADDR_LOOPBACK)
