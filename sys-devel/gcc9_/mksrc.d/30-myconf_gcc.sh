local CTARGET=${CHOST}
local HOSTTYPE=${HOSTTYPE}
local OSTYPE=${OSTYPE}

if test "X${ABI}" = 'Xx86'; then
  HOSTTYPE='i686' OSTYPE=${OSTYPE%%-*}
  # required target: <i686-linux-musl>
  CTARGET="${HOSTTYPE}-${OSTYPE}"
else
  CTARGET=${CHOST}
fi

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
 --target=${CTARGET}
 --with-abi=${ABI}  # no required - no such flag in gcc
 --with-gxx-include-dir=${INCDIR}/c++
 $(use_enable 'bootstrap')
 --enable-languages=c,c++
 $(use_enable 'openmp' libgomp)
 $(use_enable 'lto')
 $(use_enable 'libssp')
 $(use_enable 'sanitize' libsanitizer)
 $(use_enable 'multilib')
 --with-system-zlib
 --disable-libvtv
 --enable-obsolete
 --disable-gnu-indirect-function
"