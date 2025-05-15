==================================================================================================================
app-editors/hexedit0r-1.0 - undefined reference to symbol stdscr
==================================================================================================================
all -D_GNU_SOURCE -pipe  -c -o page.o page.c
gcc -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -Wall -D_GNU_SOURCE -pipe  -c -o search.o search.c
gcc  display.o file.o hexedit.o interact.o mark.o misc.o page.o search.o -o hexedit -lncurses
/bin/ld: display.o: undefined reference to symbol 'stdscr'
/bin/ld: /libx32/libtinfo.so.6: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make: *** [Makefile:26: hexedit] Error 1
Failed make build
==================================================================================================================