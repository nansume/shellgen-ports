#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="LibTomCrypt is a comprehensive, modular and portable cryptographic toolkit"
HOMEPAGE="https://www.libtom.net/LibTomCrypt/ https://github.com/libtom/libtomcrypt"
LICENSE="|| ( WTFPL-2 public-domain )"
IUSE="+gmp +libtommath -tomsfastmath"
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make V="0" \
  DESTDIR=${ED} \
  PREFIX='/usr' \
  BINPATH="${EPREFIX%/}/bin" \
  LIBPATH="/$(get_libdir)" \
  INCPATH="/usr/include" \
  -f makefile.shared \
  install \
  || die "make install... error"
