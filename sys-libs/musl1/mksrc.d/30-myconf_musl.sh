MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --host=${CHOST}
 --build=${CHOST}
 --syslibdir=${SPREFIX%/}/${LIB_DIR}
 $(use_enable 'shared')
 $(use_enable 'static-libs' static)
 --enable-wrapper=$(usex 'glibc' gcc no)
"