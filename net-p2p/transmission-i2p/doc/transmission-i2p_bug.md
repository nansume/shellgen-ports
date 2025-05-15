==================================================================================================================
net-p2p/transmission-i2p - error: invalid use of undefined type 'struct timeval'
==================================================================================================================
bob.c:61:17: warning: assignment discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
   61 |    _g_last_error="Failed to read BOB service header";
      |                 ^
bob.c: In function '_bob_do_command':
bob.c:81:55: warning: comparison of integer expressions of different signedness: 'int' and 'size_t' {aka 'unsigned int'} [-Wsign-compare]
   81 |   if( write( cctx->socket, command, strlen(command) ) == strlen( command ) ) {
      |                                                       ^~
bob.c:83:14: error: invalid use of undefined type 'struct timeval'
   83 |    _g_timeout.tv_sec=0;
      |              ^
bob.c:84:4: warning: implicit declaration of function 'select' [-Wimplicit-function-declaration]
   84 |    select(0, NULL, NULL, NULL, &_g_timeout);
      |    ^~~~~~
bob.c:84:4: warning: nested extern declaration of 'select' [-Wnested-externs]
bob.c:89:16: warning: assignment discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
   89 |   _g_last_error="Failed to send command, write failed on socket.";
      |                ^
bob.c:74:7: warning: unused variable 'response' [-Wunused-variable]
   74 |  char response[512]={0};
--------------------------------
Failed make build
==================================================================================================================

==================================================================================================================
2024-09-26 Bugfix:
==================================================================================================================
/src/main.c add:
--------------------------------
+#include <sys/time.h>
==================================================================================================================