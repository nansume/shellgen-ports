==================================================================================================================
net-vpn/tinc-1.1pre18 - error: invalid application of 'sizeof' to incomplete type 'struct options'
==================================================================================================================
  CC       openssl/rsa.o
  CCLD     tincd
  CCLD     tinc
/bin/ld: top.o: undefined reference to symbol 'stdscr'
/bin/ld: /libx32/libtinfo.so.6: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make[2]: *** [Makefile:887: tinc] Error 1
make[2]: *** Waiting for unfinished jobs....
make[2]: Leaving directory '/build/tinc-src/src'
make[1]: *** [Makefile:391: all-recursive] Error 1
make[1]: Leaving directory '/build/tinc-src'
make: *** [Makefile:332: all] Error 2
Failed make build
==================================================================================================================