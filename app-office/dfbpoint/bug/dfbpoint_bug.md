####  0518773b8aceca0f105a01c70480951c1b6ee173d85db31f9168d3c4173df325  DFBPoint-0.7.2.tar.gz

    s/-datarootdir=/-datadir=/
========================================================================================
checking DIRECTFB_LIBS... -ldirectfb -lpthread -lfusion -ldirect -lpthread
checking for pkg-config... (cached) /bin/pkg-config
checking for GLIB - version >= 2.0.3... no
*** Could not run GLIB test program, checking why...
*** The test program failed to compile or link. See the file config.log for the
*** exact error that occured. This usually means GLIB is incorrectly installed.
creating ./config.status
creating Makefile
creating examples/Makefile
creating src/Makefile
Configure directory: /build/DFBPoint-src/... ok
^[[1;32m +^[[1;36m /mksrc.d/36-pkg_compile.sh^[[m... ^[[1;33mrun^[[m
+ nice -n 19 make --jobs=4 --load-average=4 -s V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
Making all in src
header.c:22:10: fatal error: glib-object.h: No such file or directory
   22 | #include <glib-object.h>
      |          ^~~~~~~~~~~~~~~
compilation terminated.
make[1]: *** [Makefile:154: header.o] Error 1
========================================================================================