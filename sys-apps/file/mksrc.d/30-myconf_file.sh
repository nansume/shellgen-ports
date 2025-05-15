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
 $(use_enable 'static-libs' static)
 $(use_enable 'shared')
 $(use_enable 'bzip2' bzlib)
 $(use_enable 'xz' xzlib)
 $(use_enable 'zlib')
"