#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-27 10:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch +doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=saait

# BUG: no build against dietlibc

DESCRIPTION="Fast and simple static site generator"
HOMEPAGE="https://codemadness.org/saait.html"
LICENSE="ISC"
PN="saait"
PV="0.7.1"
SRC_URI="https://codemadness.org/releases/saait/${PN}-${PV}.tar.gz"
IUSE="+static -shared +doc +man (-diet) (+musl) +stest +strip"
TARGET_INST="install"

pkgins() { pkginst \
  "#dev-libs/dietlibc  #dietlibc1 # 0.34-x32 or 0.35-x86" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() { :;}
src_configure() { :;}

src_compile() {
  make -j "$(nproc)" || die "Failed make build"
}
