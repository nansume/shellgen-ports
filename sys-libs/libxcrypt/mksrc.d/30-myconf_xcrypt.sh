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
 --disable-werror
 $(use_enable 'static-libs' static)
 --disable-xcrypt-compat-files
 --enable-obsolete-api=$(usex 'compat' glibc no)
 --enable-hashes=glibc
"