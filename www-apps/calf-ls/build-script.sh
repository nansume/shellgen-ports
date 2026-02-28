#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-27 16:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/packages/calf-ls

# TODO: build against dietlibc

inherit static

DESCRIPTION="CGI file lister (depend: uriparser)"
HOMEPAGE="http://git.mg0.fr/calf/"
LICENSE="BSD3"
PN="calf"
XPN="calf-ls"
PV="2.1"
SRC_URI="http://www.mg0.fr/pub/calf/${PN}-${PV}.tar.gz"
IUSE="-fcgi +static -shared (+bundled) -doc (-diet) (+musl) +stest +strip"

pkgins() { pkginst \
  "#dev-libs/dietlibc  #dietlibc1 # 0.34-x32 or 0.35-x86" \
  "#dev-libs/fcgi" \
  "#dev-libs/uriparser  # bundled" \
  "dev-util/pkgconf" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/obstack-standalone" \
  || die "Failed install build pkg depend... error"
}

bundled_static_libs() {
  uriparser_standalone  # static-libs build bundle
}

src_prepare() {
  export LIBS="-lobstack"  # Fix for musl
}

src_install() {
  make DESTDIR="${ED}" $(usex 'strip' install-strip install) || die "make install... error"
  mv -v "${ED}"/libexec -t "${ED}"/usr/
}
