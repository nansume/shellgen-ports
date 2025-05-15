# 20231030 bootstrap muslx32 - x86_64-linux-muslx32-native.tgz 20211123 gcc-11.2.1
export CC='x86_64-linux-muslx32-gcc -static --static'
export CXX='x86_64-linux-muslx32-g++ -static --static'
#FC='x86_64-linux-muslx32-gfortran -static --static
export LDFLAGS='-s -static --static'

local CTARGET=${CHOST}
local HOSTTYPE=${HOSTTYPE}
local OSTYPE=${OSTYPE}

if test "X${ABI}" = 'Xx86'; then
  # <i686> - target may be inappropriate?
  HOSTTYPE='i386' OSTYPE=${OSTYPE%%-*}
  # required target: <i386-pc-linux-gnu>
  CTARGET="${HOSTTYPE}-pc-${OSTYPE}"  # unknow to appropriate <CHOST> ?
else
  CTARGET=${CHOST}
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
 --with-abi=${ABI}
 --with-gxx-include-dir=${INCDIR}/c++
 --disable-bootstrap
 --enable-languages=c,c++
 --disable-libgomp
 --disable-lto
 --disable-libssp
 --disable-libsanitizer
 --disable-multilib
 --with-system-zlib
 --disable-cet
 #--disable-assembly
 --disable-werror
"

MAKEFLAGS=$(mapsetre 'CC=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(mapsetre 'CXX=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})