#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The Motif user interface component toolkit"
HOMEPAGE="https://sourceforge.net/projects/motif/ https://motif.ics.com/"
LICENSE="LGPL-2.1+ MIT"
IUSE="+examples +jpeg +motif22-compatibility +png -static-libs -unicode +xft"
FILESDIR=${DISTSOURCE}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${ED}/ || return

mkdir -pm 0755 usr/share/doc/${PN}/demos/ usr/share/X11/app-defaults/

mv -n share/Xm/* usr/share/doc/${PN}/demos/ || die
mv -n "${FILESDIR}"/Mwm.defaults usr/share/X11/app-defaults/Mwm || die
printf %s\\n "Install: usr/share/doc/${PN}/demos/"

# cleanup
rm -r -- share/Xm/ || die
find "$(get_libdir)/" -type f -name "*.la" -delete || die
