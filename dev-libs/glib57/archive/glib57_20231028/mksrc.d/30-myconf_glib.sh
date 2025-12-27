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
 --enable-debug=$(usex 'debug' yes no)
 $(use_enable 'doc' gtk-doc-html)
 $(use_enable 'fam')
 $(use_enable 'doc' gtk-doc)
 $(use_enable 'mount' libmount)
 $(use_enable 'man')
 $(use_enable 'xattr')
 $(use_enable 'static-lib' static)
 $(use_enable 'shared')
"