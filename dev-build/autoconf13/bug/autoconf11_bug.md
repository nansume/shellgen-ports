sys-devel/autoconf-2.11 - error: wrong a installdir
===============================================================================================================
BUILD_DIR='/build/autoconf-src'
^[[1;32m +^[[0;36m /mksrc.d/40-pre_makeinstall.sh^[[m... ^[[0;33mrun^[[m
MAKEFLAGS='-j4 V=0 PREFIX= USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile DESTDIR=/install INSTALLROOT=/install INSTALL_PREFIX=/install BUILDROOT=/install LIB=libx32 LIBPREFIX=/libx32 INCPREFIX=/usr/include BIN=/install/bin DATADIR=/usr/share MANDIR=/install/usr/share/man/man1 MANPREFIX=/usr/share/man LTLIBRARIES='
^[[1;32m +^[[0;36m /mksrc.d/42-pre_install.sh^[[m... ^[[0;33mrun^[[m
LD_PRELOAD=libfakeroot.so make -j4 V=0 PREFIX= USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile DESTDIR=/install INSTALLROOT=/install INSTALL_PREFIX=/install BUILDROOT=/install LIB=libx32 LIBPREFIX=/libx32 INCPREFIX=/usr/include BIN=/install/bin DATADIR=/usr/share MANDIR=/install/usr/share/man/man1 MANPREFIX=/usr/share/man LTLIBRARIES= install
/bin/sh ./mkinstalldirs /bin //info /usr/share/autoconf
mkdir //info
mkdir /usr/share/autoconf
mkdir: can't create directory '/usr/share/autoconf': Permission denied
make: *** [Makefile:124: installdirs] Error 1
===============================================================================================================