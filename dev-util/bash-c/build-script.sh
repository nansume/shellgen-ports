#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-22 17:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl +stest -strip +noarch

# https://aur.archlinux.org/packages/c

DESCRIPTION="Compile and execute C scripts in one go Bash"
HOMEPAGE="https://github.com/ryanmjacobs/c"
LICENSE="MIT"
PN="bash-c"
SPN="c"
PV="0.15.1"
SRC_URI="https://github.com/ryanmjacobs/c/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE=""
BUILD_DIR="${WORKDIR}/${SPN}-${PV}"

pkgins() { :;}
prepare() { :;}
src_configure() { :;}
src_compile() { :;}

src_install() {
  install -Dm 755 ${SPN} "${ED}"/bin/${PN}
}
