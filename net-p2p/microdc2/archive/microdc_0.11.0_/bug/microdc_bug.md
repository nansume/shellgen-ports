net-p2p/microdc-0.11.0 - error: assignment to expression with array type
===============================================================================================================
gcc -DHAVE_CONFIG_H -I. -I. -I..     -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -std=c99 -c version-etc.c
gcc -DHAVE_CONFIG_H -I. -I. -I..     -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -std=c99 -c xalloc-die.c
version-etc.c: In function 'version_etc_va':
version-etc.c:56:17: error: assignment to expression with array type
   56 |     tmp_authors = authors;
      |                 ^
make[3]: *** [Makefile:317: version-etc.o] Error 1
-----------------
Failed make build
===============================================================================================================

BUGFIX?:
------------------------------------------------------
pkginst "sys-libs/readline4"  # no, it nowork
------------------------------------------------------

---------------------------------------------------------------------------------------------------------------
[C Programming: error: assignment to expression with array type](https://stackoverflow.com/questions/61827741/)
---------------------------------------------------------------------------------------------------------------