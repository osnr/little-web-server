local ffi = require 'ffi'
ffi.cdef[[
int socket(int domain, int type, int protocol);
typedef uint32_t socklen_t;
int setsockopt(int sockfd, int level, int optname,
                      const void *optval, socklen_t optlen);
static const int SOL_SOCKET = 1;
static const int SO_REUSEADDR = 2;
typedef uint16_t in_port_t;
/* POSIX.1g specifies this type name for the `sa_family' member.  */
typedef unsigned short int sa_family_t;
static const sa_family_t AF_INET = 2; /* IP protocol family.  */
static const int SOCK_STREAM = 1; /* Sequenced, reliable, connection-based
		              byte streams.  */
/* Internet address. */
struct in_addr {
    uint32_t       s_addr;     /* address in network byte order */
};
struct sockaddr_in {
    sa_family_t    sin_family; /* address family: AF_INET */
    in_port_t      sin_port;   /* port in network byte order */
    struct in_addr sin_addr;   /* internet address */
    char    sin_zero[8];
};
uint16_t htons(uint16_t hostshort);
uint32_t htonl(uint32_t hostlong);
static const uint32_t INADDR_ANY = 0x00000000;
int bind(int sockfd, const struct sockaddr_in *addr, socklen_t addrlen);
int listen(int sockfd, int backlog);
int accept(int sockfd, struct sockaddr_in *addr, socklen_t *addrlen);
ssize_t send(int sockfd, const void *buf, size_t len, int flags);
static const int SHUT_WR = 1;
int shutdown(int sockfd, int how);
int close(int fd);
char *strerror(int errnum);
]]

local function cassert(cond)
   if not cond then error(ffi.string(ffi.C.strerror(ffi.errno()))) end
end

local socket = ffi.C.socket(ffi.C.AF_INET, ffi.C.SOCK_STREAM, 0)
cassert(socket ~= -1)
local optval = ffi.new('int[1]', 1)
cassert(ffi.C.setsockopt(socket, ffi.C.SOL_SOCKET, ffi.C.SO_REUSEADDR,
                         optval, ffi.sizeof('int')) >= 0)

local addr = ffi.new('struct sockaddr_in')
addr.sin_family = ffi.C.AF_INET
addr.sin_port = ffi.C.htons(8080)
addr.sin_addr.s_addr = ffi.C.htonl(ffi.C.INADDR_ANY)

cassert(ffi.C.bind(socket, addr, ffi.sizeof(addr)) ~= -1)

ffi.C.listen(socket, 10) -- backlog = 10

local function send(client, data)
   ffi.C.send(client, data, #data, 0)
end

local response = "HTTP/1.1 200 OK\r\n\nhello\r\n"
local chars = {}
for c in string.gmatch(response, ".") do
   table.insert(chars, c)
end


while true do
   local client = ffi.C.accept(socket, nil, nil)
   for _, chunk in ipairs(chars) do
      send(client, chunk)
   end
   ffi.C.shutdown(client, ffi.C.SHUT_WR)
   ffi.C.close(client)
end
