#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-26 21:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=ssg

DESCRIPTION="make a static site with find(1), grep(1), and lowdown or Markdown.pl - rgz.e"

HOMEPAGE="https://romanzolotarev.com/ssg/"
LICENSE="ISC"
PN="ssg"
PV="7"
XPV="7.4.0"
HASH="b5a8db69db99f84c0c4b5c56a7f329c275b341d4"  # v7.4.0
SRC_URI="https://got.romanzolotarev.com/?action=blobraw&commit=${HASH}&file=ssg.sh&folder=&path=ssg.git -> ssg7.sh"
IUSE="-doc -stest"
BUILD_DIR="${FILESDIR}"

pkgins() { :;}
src_prepare() { :;}
src_configure() { :;}
src_compile() { :;}

src_install() {
  install -d "${ED}"/bin/
  install -m755 "ssg7.sh" "${ED}"/bin/${PN} || die "make install... error"
  sed -e 's| ksh | sh |' -i "${ED}"/bin/${PN}  # posix compat
}
