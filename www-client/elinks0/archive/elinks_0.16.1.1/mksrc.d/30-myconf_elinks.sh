case ${CHOST} in
  *'muslx32')
    # Invalid configuration <x86_64-linux-muslx32>: system <muslx32> not recognized
    P_CHOST='x86_64-linux-gnux32'
  ;;
esac

MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --sbindir=${SPREFIX%/}/sbin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --libexecdir=${DPREFIX}/libexec
 --datarootdir=${DPREFIX}/share
 --host=${P_CHOST}
 --build=${P_CHOST}
 #--disable-bookmarks
 #--disable-cookies
 #--disable-css
 #--disable-data
 #--disable-formhist
 #--disable-ipv6
 #--without-zlib
 #--with-perl
 #--with-terminfo
 #--without-openssl
 #--with-gnutls  # no build
 --enable-cgi
 --enable-fastmem
 --enable-nntp
 --enable-finger
 --enable-gopher
 --without-x
 --disable-backtrace
 --without-bzlib
 --without-gpm
 --without-idn
 --disable-marks
 --disable-mouse
 --without-tre
 --disable-uri-rewrite
 --disable-xbel
 --without-zstd
"
