################################################
#####  loudmouth_1.5.3 - lm-sasl.lo Error  #####
################################################

/bin/sh ../libtool  --tag=CC   --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I..  -I. -I.. -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include   -DLM_COMPILATION -DRUNTIME_ENDIAN    -O2 -msse -ftree-vectorize -g0 -march=i686 -mfpmath=sse,387 -Wall -Wall -Wunused -Wchar-subscripts -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wno-sign-compare -Werror -c -o lm-sasl.lo lm-sasl.c
libtool: compile:  i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I. -I.. -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -DLM_COMPILATION -DRUNTIME_ENDIAN -O2 -msse -ftree-vectorize -g0 -march=i686 -mfpmath=sse,387 -Wall -Wall -Wunused -Wchar-subscripts -Wmissing-declarations -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wno-sign-compare -Werror -c lm-sasl.c  -fPIC -DPIC -o .libs/lm-sasl.o
lm-sasl.c: In function 'sasl_md5_prepare_response':
lm-sasl.c:532:32: error: comparison between pointer and zero character constant [-Werror=pointer-compare]
     if (nonce == NULL || nonce == '\0') {
                                ^~
lm-sasl.c:532:26: note: did you mean to dereference the pointer?
     if (nonce == NULL || nonce == '\0') {
                          ^
cc1: all warnings being treated as errors
make[3]: *** [Makefile:670: lm-sasl.lo] Error 1
make[3]: Leaving directory 'loudmouth_1.5.3-src/loudmouth-1.5.3/loudmouth'
make[2]: *** [Makefile:523: all] Error 2
make[2]: Leaving directory 'loudmouth-1.5.3-src/loudmouth-1.5.3/loudmouth'
make[1]: *** [Makefile:512: all-recursive] Error 1
make[1]: Leaving directory 'loudmouth-1.5.3-src/loudmouth-1.5.3'
make: *** [Makefile:420: all] Error 2


# fails to compile with gcc_7.1.0 lm-sasl.c:532:32: error: comparison between pointer and zero character constant [-Werror=pointer-compare]
#  [lang-en,ipv6,ssl]
http://bugs.gentoo.org/show_bug.cgi?id=618330


fix: update