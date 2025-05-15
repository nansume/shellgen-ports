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
 $(use_enable 'acl')
 $(use_enable 'caps' libcap)
 $(use_enable 'smack' libsmack)
 $(use_enable 'threads')
 $(use_enable 'multicall' single-binary)
 $(use_enable 'xattr')
 $(use_enable 'nls')
 $(use_enable 'rpath')
 $(use_with 'gmp')
"

use 'static' && MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }LDFLAGS=-static"