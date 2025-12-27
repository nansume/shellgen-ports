#######  error x32 overflow - required fix  #######
  CC       lib/nsutils.o
  CC       pmap.o
pmap.c:136:36: warning: conversion from 'long long unsigned int' to 'long unsigned int' changes value from '18446744073709551615' to '4294967295' [-Woverflow]
  136 | static unsigned KLONG range_high = ~0ull;
      |                                    ^
  CC       pwdx.o
  CC       tload.o
  CC       uptime.o
####################################################



#######  nowork:  symlink: curses.h --> ncurses.h  #######
  CC       vmstat.o
  CC       w.o
  CC       slabtop.o
slabtop.c:31:10: fatal error: ncurses.h: No such file or directory
   31 | #include <ncurses.h>
      |          ^~~~~~~~~~~
compilation terminated.
make[2]: *** [Makefile:1552: slabtop.o] Error 1
###############################################

[fix]: rebuild <ncurses> dir include:  `/usr/include/ncurses --> /usr/include`
##########################################################