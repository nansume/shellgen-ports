==================================================================================================================
www-servers/ciwiki-3.0.4 - undefined reference to <strcasestr>, if build against dietlibc.
==================================================================================================================
  CCLD     ciwiki
/bin/ld: ci.o: in function `main':
ci.c:(.text.startup.main+0x417): warning: warning: your code still has assertions enabled!
/bin/ld: /opt/diet/lib-x32/libc.a(sprintf.o): in function `sprintf':
(.text+0x77): warning: warning: Avoid *sprintf; use *snprintf. It is more secure.
/bin/ld: /opt/diet/lib-x32/libc.a(stderr.o): in function `__fflush_stderr':
(.text+0x7): warning: warning: your code uses stdio (7+k bloat).
/bin/ld: http.o: in function `http_request_new':
http.c:(.text.http_request_new+0xd7): warning: setenv calls malloc.  Avoid it in small programs.
/bin/ld: /opt/diet/lib-x32/libc.a(vsnprintf.o): in function `vsnprintf':
(.text+0x82): warning: warning: the printf functions add several kilobytes of bloat.
/bin/ld: http.o: in function `http_request_new':
http.c:(.text.http_request_new+0x5bc): undefined reference to `strcasestr'
/bin/ld: wiki.o: in function `wiki_get_pages':
wiki.c:(.text.wiki_get_pages+0xd9): undefined reference to `strcasestr'
/bin/ld: wiki.c:(.text.wiki_get_pages+0xe9): undefined reference to `strcasestr'
/bin/ld: wiki.o: in function `wiki_show_search_results_page':
wiki.c:(.text.wiki_show_search_results_page+0xfe): undefined reference to `strcasestr'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:347: ciwiki] Error 1
---------------------------------------------------------------------------------------
Failed make build
==================================================================================================================

# bugfix
----------------------------------------------------------------------------------------------
build against <musl-libc> or <glibc>
----------------------------------------------------------------------------------------------