==================================================================================================================
net-misc/ssocks-0.0.14 - error: unknown type name 'fd_set'
==================================================================================================================
libtool: compile:  gcc -DHAVE_CONFIG_H -I. -I../.. -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -mx32 -msse2 -Os -ffunction-sections -fdata-sections -fno-stack-protector -no-pie -g0 -march=x86-64 -MT socks5-client.lo -MD -MP -MF .deps/socks5-client.Tpo -c socks5-client.c  -fPIC -DPIC -o .libs/socks5-client.o
In file included from socks5-client.c:30:
socks5-client.h:46:40: error: unknown type name 'fd_set'
   46 | void dispatch_client(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                        ^~~~~~
socks5-client.h:46:58: error: unknown type name 'fd_set'
   46 | void dispatch_client(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                                          ^~~~~~
libtool: compile:  gcc -DHAVE_CONFIG_H -I. -I../.. -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -mx32 -msse2 -Os -ffunction-sections -fdata-sections -fno-stack-protector -no-pie -g0 -march=x86-64 -MT output-util.lo -MD -MP -MF .deps/output-util.Tpo -c output-util.c -o output-util.o >/dev/null 2>&1
socks5-client.h:48:41: error: unknown type name 'fd_set'
   48 | void dispatch_dynamic(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                         ^~~~~~
socks5-client.h:48:59: error: unknown type name 'fd_set'
   48 | void dispatch_dynamic(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                                           ^~~~~~
socks5-client.h:51:3: error: unknown type name 'fd_set'
   51 |   fd_set *set_read, fd_set *set_write);
socks5-client.h:51:21: error: unknown type name 'fd_set'
   51 |   fd_set *set_read, fd_set *set_write);
      |                     ^~~~~~
socks5-client.h:54:3: error: unknown type name 'fd_set'
   54 |   fd_set *set_read, fd_set *set_write);
      |   ^~~~~~
socks5-client.h:54:21: error: unknown type name 'fd_set'
   54 |   fd_set *set_read, fd_set *set_write);
      |                     ^~~~~~
In file included from socks5-client.c:31:
socks5-server.h:52:39: error: unknown type name 'fd_set'
   52 | int dispatch_server(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                       ^~~~~~
socks5-server.h:52:57: error: unknown type name 'fd_set'
   52 | int dispatch_server(s_client *client, fd_set *set_read, fd_set *set_write);
      |                                                         ^~~~~~
socks5-server.h:67:37: error: unknown type name 'fd_set'
   67 |   s_buffer *buf_stream, int *maxfd, fd_set *set_read, fd_set *set_write);
      |                                     ^~~~~~
socks5-server.h:67:55: error: unknown type name 'fd_set'
   67 |   s_buffer *buf_stream, int *maxfd, fd_set *set_read, fd_set *set_write);
      |                                                       ^~~~~~
socks5-server.h:69:37: error: unknown type name 'fd_set'
   69 |   s_buffer *buf_stream, int *maxfd, fd_set *set_read, fd_set *set_write);
      |                                     ^~~~~~
socks5-server.h:69:55: error: unknown type name 'fd_set'
   69 |   s_buffer *buf_stream, int *maxfd, fd_set *set_read, fd_set *set_write);
      |                                                       ^~~~~~
socks5-server.h:72:3: error: unknown type name 'fd_set'

   72 |   fd_set *set_read, fd_set *set_write);
      |   ^~~~~~
socks5-server.h:72:21: error: unknown type name 'fd_set'
   72 |   fd_set *set_read, fd_set *set_write);
      |                     ^~~~~~
socks5-server.h:75:13: error: unknown type name 'fd_set'
   75 |   int ncon, fd_set *set_read, fd_set *set_write, int ssl);
      |             ^~~~~~
socks5-server.h:75:31: error: unknown type name 'fd_set'
   75 |   int ncon, fd_set *set_read, fd_set *set_write, int ssl);
      |                               ^~~~~~
Failed make build
==================================================================================================================

==================================================================================================================
Bugfix for - error: unknown type name 'fd_set'
==================================================================================================================
/src/main.c add:
------------------------------------------------------------------------------------------------------------------
#include <sys/select.h>
==================================================================================================================