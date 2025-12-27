==================================================================================================================
app-arch/unrar-free-0.3.0 - undefined reference to `argp_usage'
==================================================================================================================
Making all in src
make[2]: Entering directory '/build/unrar-free-src/src'
  CC       unrar_free-unrar.o
  CC       unrar_free-opts.o
unrar.c: In function 'main':
unrar.c:548:43: warning: assignment to 'const char **' from incompatible pointer type 'char **' [-Wincompatible-pointer-types]
  548 |     arguments.unrar.multivolume_filenames = pglob.gl_pathv;
      |                                           ^
  CCLD     unrar-free
/bin/ld: unrar_free-opts.o: in function `parse_opt':
opts.c:(.text+0x3f5): undefined reference to `argp_usage'
/bin/ld: opts.c:(.text+0x41c): undefined reference to `argp_usage'
/bin/ld: unrar_free-opts.o: in function `parse_opts':
opts.c:(.text+0x676): undefined reference to `argp_parse'
/bin/ld: opts.c:(.text+0x6c4): undefined reference to `argp_help'
/bin/ld: opts.c:(.text+0x6fa): undefined reference to `argp_help'
ollect2: error: ld returned 1 exit status
make[2]: *** [Makefile:352: unrar-free] Error 1
make[2]: Leaving directory '/build/unrar-free-src/src'
make[1]: *** [Makefile:441: all-recursive] Error 1
make[1]: Leaving directory '/build/unrar-free-src'
make: *** [Makefile:339: all] Error 2
==================================================================================================================