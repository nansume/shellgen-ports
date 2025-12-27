==================================================================================================================
net-irc/bnc-2.9.4 - error: unknown type name 'u_short'
==================================================================================================================
conf.c:634:18: warning: pointer targets in passing argument 1 of 'strtok' differ in signedness [-Wpointer-sign]
  634 |    tmp = strtok (linbuff, " \n\r,");
      |                  ^~~~~~~
      |                  |
      |                  unsigned char *
In file included from conf.c:5:
/usr/include/string.h:52:7: note: expected 'char * restrict' but argument is of type 'unsigned char *'
   52 | char *strtok (char *__restrict, const char *__restrict);
      |       ^~~~~~
cmds.c:37:57: error: unknown type name 'u_short'; did you mean 'short'?
   37 | int irc_connect(struct cliententry *cptr, char *server, u_short port, char *pass, int ctype, int cflags);
      |                                                         ^~~~~~~
      |                                                         short
cmds.c: In function 'handlepclient':
cmds.c:378:7: warning: implicit declaration of function 'irc_connect'; did you mean 'connect'? [-Wimplicit-function-declaration]
  378 |     r=irc_connect(cptr, cptr->autoconn, cptr->sport, cptr->autopass, 0, 0);
      |       ^~~~~~~~~~~
      |       connect
cmds.c:404:13: warning: pointer targets in passing argument 1 of 'fgets' differ in signedness [-Wpointer-sign]
  404 |      fgets (motdb,MAXMOTDLINE, motdf);
==================================================================================================================
Build... Failed!
==================================================================================================================