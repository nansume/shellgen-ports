#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit flag-o-matic toolchain-funcs xdg desktop install-functions

DESCRIPTION="a lightweight PDF viewer and toolkit written in portable C"
HOMEPAGE="https://mupdf.com/"
LICENSE="AGPL-3"
IUSE="+X -javascript -libressl -opengl -ssl -static-libs +vanilla"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

use 'javascript' || sed \
  -e '/* #define FZ_ENABLE_JS/ a\#define FZ_ENABLE_JS 0' \
  -i include/mupdf/fitz/config.h

sed -e "1iOS = Linux" \
  -e "1iCC = ${CC}" \
  -e "1iLD = ld" \
  -e "1iAR = ar" \
  -e "1iverbose = yes" \
  -e "1ibuild = debug" \
  -e "1iprefix = /usr" \
  -e "1ibindir = /bin" \
  -e "1ilibdir = /$(get_libdir)" \
  -e "1idocdir = /usr/share/doc/${PN}-${PV}" \
  -i Makerules || die

if use 'X' || use 'opengl'; then
  domenu platform/debian/${PN}.desktop
  doicon platform/debian/${PN}.xpm
else
  rm -- docs/man/${PN}.1
fi

make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  GENTOO_PV=${PV} \
  HAVE_GLUT=$(usex 'opengl') \
  HAVE_LIBCRYPTO=$(usex 'ssl') \
  WANT_X11=$(usex 'X') \
  HAVE_OBJCOPY="no" \
  XCFLAGS="-fpic" \
  install \
  || die "Failed make build"

use 'static-libs' && {
make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  GENTOO_PV=${PV} \
  HAVE_GLUT=$(usex 'opengl') \
  HAVE_LIBCRYPTO=$(usex 'ssl') \
  WANT_X11=$(usex 'X') \
  HAVE_OBJCOPY="no" \
  XCFLAGS="-fpic" \
  build/debug/lib${PN}.a \
  install \
  || die "Failed make build"
}

rm -- Makefile

dosym libmupdf.so.${PV} /$(get_libdir)/lib${PN}.so

use 'static-libs' && dolib.a build/debug/lib${PN}.a
if use 'opengl'; then
  dosym ${PN}-gl /bin/${PN}
elif use 'X'; then
  dosym ${PN}-x11 /bin/${PN}
fi
insinto /$(get_libdir)/pkgconfig
doins platform/debian/${PN}.pc

dodoc README CHANGES CONTRIBUTORS

printf %s\\n "Install: ${PN}"
