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
 $(use_enable 'shared')
 $(use_enable 'static-libs' static)
 $(use_enable 'nls')
 $(use_enable 'rpath')
"