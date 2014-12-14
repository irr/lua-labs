local ffi = require "ffi"

ffi.cdef[[
static const int PF_INET = 2;
static const int AF_INET = PF_INET;
static const int SOCK_STREAM = 1;

void bzero(void *s, size_t n);

int socket(int domain, int type, int protocol);

typedef uint32_t socklen_t;

static const int SOL_SOCKET = 1;
static const int SO_REUSEADDR = 2;

typedef unsigned short int sa_family_t;
typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;

struct in_addr {
  in_addr_t s_addr;
};

static const int INADDR_ANY = (in_addr_t)0x00000000;

struct sockaddr {
  sa_family_t sin_family;
  char sa_data[14];
};

struct sockaddr_in {
  sa_family_t sin_family;
  in_port_t sin_port;
  struct in_addr sin_addr;

  unsigned char sin_zero[sizeof(struct sockaddr) -
       sizeof(sa_family_t) -
       sizeof(in_port_t) -
       sizeof(struct in_addr)];
};

uint16_t htons(uint16_t hostshort);
uint32_t htonl(uint32_t hostlong);
uint16_t ntohs(uint16_t netshort);

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);

int listen(int sockfd, int backlog);

int getsockname(int sockfd, struct sockaddr *addr, socklen_t *addrlen);

int close(int fd);
]]

local C = ffi.C

local listenfd = C.socket(C.AF_INET, C.SOCK_STREAM, 0)

local servaddr = ffi.new("struct sockaddr_in[1]")
C.bzero(ffi.cast("struct sockaddr *", servaddr), ffi.sizeof(servaddr));

servaddr[0].sin_family = C.AF_INET
servaddr[0].sin_addr.s_addr=C.htonl(C.INADDR_ANY);
servaddr[0].sin_port = C.htons(0);

rc = C.bind(listenfd, ffi.cast("struct sockaddr *", servaddr), ffi.sizeof(servaddr))
assert(rc == 0)

rc = C.listen(listenfd, 1024)
assert(rc == 0)

local len = ffi.new("int32_t[1]", ffi.sizeof(servaddr))
rc = C.getsockname(listenfd, ffi.cast("struct sockaddr *", servaddr), len)
assert(rc == 0)

print(string.format("port: %d\n", C.ntohs(servaddr[0].sin_port)));

rc = C.close(listenfd)
assert(rc == 0)
