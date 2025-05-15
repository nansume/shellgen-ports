#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

# https://data.gpo.zugaina.org/gentoo/app-text/pdf2html/pdf2html-1.4.ebuild

DESCRIPTION="Converts pdf files to html files"
HOMEPAGE="http://atrey.karlin.mff.cuni.cz/~clock/twibright/pdf2html/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS="pbm2png pbm2eps9 ${PN} ps2eps9"

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

echo "cp \"${EPREFIX%/}\"/usr/share/${PN}-${PV}/*.png ." >> pdf2html || die "echo #4 failed"

mkdir -pm 0755 -- "${ED}"/bin/ "${ED}"/usr/share/${PN}-${PV}/
mv -n ${PROGS} -t "${ED}"/bin/ &&
mv -n *.png *.html -t "${ED}"/usr/share/${PN}-${PV}/ &&
printf %s\\n "Install: ${PROGS} bin/"
