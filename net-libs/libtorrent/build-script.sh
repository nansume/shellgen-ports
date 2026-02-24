#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: BitTorrent library written in C++ for *nix
# Homepage: https://rtorrent.net
# License: GPL-2
# Depends: <deps>
# Date: 2026-02-10 13:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/libtorrent/libtorrent-0.16.6.ebuil

PN="libtorrent"
PV="0.16.6"
SRC_URI="https://github.com/rakshasa/rtorrent/releases/download/v${PV}/${PN}-${PV}.tar.gz"
IUSE="-debug -test +static-libs +shared -doc (+musl) +stest +strip"

pkgins(){ pkginst \
  "dev-libs/gmp  # deps tls" \
  "dev-libs/openssl3" \
  "dev-util/pkgconf" \
  "net-misc/curl8-2" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"
}

build(){
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --enable-aligned \
    $(use_enable 'debug') \
    --with-posix-fallocate \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  find "${ED}/$(get_libdir)" -type f -name '*.la' -delete || die
}
