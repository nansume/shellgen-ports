#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-23 17:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/guru/dev-util/tinyxxd/tinyxxd-1.3.11.ebuild

# TODO: replace to: build against diet-libc

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Drop-in replacement and standalone version of xxd"
HOMEPAGE="https://github.com/xyproto/tinyxxd"
LICENSE="|| ( GPL-2 MIT )"
PN="tinyxxd"
PV="1.3.11"
SRC_URI="https://github.com/xyproto/${PN}/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="+xxd -test +static -shared -doc (+musl) +stest +strip"
PATCH_URI="http://data.gpo.zugaina.org/guru/${CATEGORY}/${PN}/files"
PATCHES="${FILESDIR}/${PN}-1.3.11-fixes.patch"
TARGET_INST=

pkgins() { pkginst \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_configure() { :;}

src_compile() {
  export CFLAGS LDFLAGS
  tc-export CC
  emake
}

src_install() {
  emake DESTDIR="${ED}" PREFIX="${EPREFIX%/}" install
  if use 'xxd'; then
    dosym -r /bin/tinyxxd /bin/xxd
  fi
}
