#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-26 21:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

# https://iso.netbsd.org/pub/NetBSD/NetBSD-current/pkgsrc/www/august/index.html

DESCRIPTION="Simple Tk-based HTML editor (It's distributed as a single script)."
HOMEPAGE="https://www.erjobe.info/index.php?n=Main.August"
LICENSE="GPL-2"
PN="august"
PV="0.63b"
SRC_URI="https://www.erjobe.info/mainwiki/pmwiki/uploads/Main/August/${PN}${PV}.src.tar.gz"
IUSE="-doc -stest"
BUILD_DIR="${WORKDIR}/${PN}${PV}.src"

pkgins() { :;}
src_prepare() { :;}
src_configure() { :;}
src_compile() { :;}

src_install() {
  mkdir -m 0755 ${ED}/bin/
  mv -v ${PN} -t ${ED}/bin/ || die "make install... error"
  if use 'doc'; then
    mkdir -p -m 0755 ${ED}/usr/share/doc/august/
    mv -v license.txt -t ${ED}/usr/share/doc/august/
    mv -v readme.txt -t ${ED}/usr/share/doc/august/
    mv -v specchars.txt -t ${ED}/usr/share/doc/august/
    mv -v keyname.tcl -t ${ED}/usr/share/doc/august/
  fi
}
