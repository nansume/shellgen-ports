#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The OpenGL Extension Wrangler Library"
HOMEPAGE="http://glew.sourceforge.net/"
LICENSE="BSD MIT"
IUSE="-doc -static-libs"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make \
  DESTDIR=${ED} \
  LIBDIR="/$(get_libdir)" \
  PKGDIR="/$(get_libdir)/pkgconfig" \
  install || die "make install... error"

printf %s\\n "Install: ${PN}"
