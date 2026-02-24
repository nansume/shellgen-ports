#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-23 21:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-util/shc/shc-4.0.3.ebuild

# BUG: build aginst dietlibc: undefined reference to `rpl_malloc`

EAPI=8

inherit install-functions

DESCRIPTION="A (shell-) script compiler/scrambler"
HOMEPAGE="https://github.com/neurobin/shc https://neurobin.org/projects/softwares/unix/shc/"
LICENSE="GPL-2"
PN="shc"
PV="4.0.3"
SRC_URI="https://github.com/neurobin/${PN}/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="-test +static -shared -doc (+musl) +stest +strip"
TARGET_INST=

pkgins() { pkginst \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_configure() {
  ./configure --host=$(tc-chost) || die "configure... error"
}

src_compile() {
  make -j "$(nproc)" || die "Failed make build"
}

src_install() {
  dobin src/shc || die "make install... error"
  use 'doc' || return 0
  doman shc.1
  dodoc ChangeLog README.md
}
