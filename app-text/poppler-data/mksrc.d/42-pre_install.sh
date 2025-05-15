#!/bin/sh
# -static -static-libs -shared -patch -doc -xstub -diet -musl +stest +strip +x32

DESCRIPTION="Data files for poppler to support uncommon encodings without xpdfrc"
HOMEPAGE="https://poppler.freedesktop.org/"
LICENSE="AGPL-3+ BSD GPL-2 MIT"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make prefix="/usr" DESTDIR=${ED} install || die "make install... error"

# We need to include extra cMaps for ghostscript, bug #844115
cp Identity-* "${ED}"/usr/share/poppler/cMap/ || die

# bug #409361
mkdir -pm 0755 "${ED}"/usr/share/poppler/cMaps/
cd "${ED}"/usr/share/poppler/cMaps/ || die
find ../cMap -type f -exec ln -s {} . \; || die
