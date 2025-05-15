#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit install-functions

DESCRIPTION="Kanji quiz and a lookup tool for X, helps in memorizing Japanese characters"
HOMEPAGE="http://www.bolthole.com/kdrill/"
LICENSE="kdrill"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

local D=${ED}

export PN PV ED INCROOT

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

# getline is already defined by libc
sed -i -e 's#getline(#my_&#g' *.c *.h

mv -n Imakefile Imakefile.orig
echo "DESTDIR=\"${D}\"" > Imakefile
echo "CFLAGS+=${CFLAGS}" >> Imakefile
echo "LDFLAGS+=${LDFLAGS}" >> Imakefile
echo "INCROOT=${INCDIR}" >> Imakefile
cat Imakefile.orig >> Imakefile
sed s,/usr/local/lib,/usr/share/kdrill,g -i Imakefile
xmkmf || die "xmkmf failed"

make V='0' -j"$(nproc)" || die "make failed"

make DESTDIR=${ED} install || die "emake install failed"
dobin makedic/makedic makedic/makeedict

dodoc LICENSE NOTES README PATCHLIST BUGS TODO

mv -n kdrill.man kdrill.1
doman kdrill.1 makedic/makedic.1 makedic/makeedict.1

insinto /usr/share/pixmaps
doins kdrill.xpm

insinto /usr/share/kdrill
gzip kanjidic
doins makedic/*.edic kanjidic.gz
rm -- ${D}/lib/X11/app-defaults

rm -- Makefile
printf %s\\n "Install: ${PN}"
