export ED DESTDIR DOCS

BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
DESTDIR=${ED}
DOCS="ChangeLog NEWS README NOTICE AUTHORS"

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

emake DESTDIR=${ED} INSTALL_PREFIX="${ED}/usr/share" install || die "make install... error"
