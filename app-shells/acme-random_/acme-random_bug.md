==================================================================================================================
app-shells/acme-random-14Aug2014 - undefined reference to srandomdev
==================================================================================================================
gcc -O -ansi -pedantic -U__STRICT_ANSI__ -Wall -Wpointer-arith -Wshadow -Wcast-qual -Wcast-align -Wstrict-prototypes -Wmissing-prototypes -Wmissing-declarations -Wredundant-decls -Wno-long-long random.c  -o random
random.c: In function 'main':
random.c:64:2: warning: implicit declaration of function 'srandomdev'; did you mean 'srandom'? [-Wimplicit-function-declaration]
   64 |  srandomdev();
      |  ^~~~~~~~~~
      |  srandom
/bin/ld: /tmp/ccBLGoji.o: in function `main':
random.c:(.text+0x11e): undefined reference to `srandomdev'
collect2: error: ld returned 1 exit status
make: *** [Makefile:10: random] Error 1
==================================================================================================================