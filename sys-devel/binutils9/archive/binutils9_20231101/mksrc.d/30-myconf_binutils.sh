if use 'static'; then
  export CC="gcc -static --static"
  export CXX="g++ -static --static"
  export LDFLAGS='-s -static --static'

  MAKEFLAGS=$(mapsetre 'CC=*' '' ${MAKEFLAGS})
  MAKEFLAGS=$(mapsetre 'CXX=*' '' ${MAKEFLAGS})
  MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})
fi

MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --sbindir=${SPREFIX%/}/sbin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --libexecdir=${DPREFIX}/libexec
 --datarootdir=${DPREFIX}/share
 --host=${CHOST}
 --build=${CHOST}
 $(use_enable 'rpath')
 $(use_enable 'nls')
 $(use_enable 'shared')
 $(use_enable 'static-libs' static)
 --exec-prefix=${DPREFIX}
 $(use_enable 'threads')
 $(use_enable 'gold')
 --enable-ld=default
 $(use_enable 'multilib')
 --disable-werror
 $(use_enable 'plugins')
 --with-system-zlib
"