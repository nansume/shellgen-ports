#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: BitTorrent Client using libtorrent
# Homepage: https://rtorrent.net
# License: GPL-2
# Depends: +libcurl +libncurses +libatomic +libopenssl +libstdcpp +zlib
# Date: 2026-02-11 15:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-p2p/rtorrent/rtorrent-0.16.6.ebuild
# https://github.com/openwrt/openwrt-community/archive/master.tar.gz  package/net/rtorrent/Makefile

# BUG: install phase: Segmentation fault  [close]

EAPI=8

inherit install-functions autotools lua toolchain-funcs

PN="rtorrent"
PV="0.16.6"
SRC_URI="
  https://github.com/rakshasa/rtorrent/releases/download/v${PV}/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/net-p2p/rtorrent/files/rtorrent.1
  http://data.gpo.zugaina.org/gentoo/net-p2p/rtorrent/files/rtorrent-r1.init
  http://data.gpo.zugaina.org/gentoo/net-p2p/rtorrent/files/rtorrentd.conf
"
IUSE="-debug -lua -selinux -test +tinyxml2 -xmlrpc +static -shared -doc (+musl) +stest +strip"

pkgins() { pkginst \
  "#dev-cpp/nlohmann_json" \
  "dev-libs/gmp  # deps libtorrent" \
  "dev-libs/openssl3  # deps libtorrent" \
  "dev-util/pkgconf" \
  "net-dns/c-ares  # deps libtorrent" \
  "net-libs/libtorrent" \
  "net-misc/curl8-2  # deps libtorrent" \
  "sys-apps/file" \
  "sys-apps/gawk  # FIX: install-sh: Segmentation fault (busybox awk no-compat)" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/netbsd-curses" \
  "sys-libs/zlib  # deps libtorrent" \
  || die "Failed install build pkg depend... error"
}

build() {
  # https://github.com/rakshasa/rtorrent/issues/332
  cp "${FILESDIR}"/rtorrent.1 "${S}"/doc/ || die

  ./configure \
    LIBS="$(usex 'static' '-lz -lcurl -lcares -lssl -lcrypto -l:libgmp.a' '-lcurl')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --datadir="${EPREFIX%/}"/usr/share \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-execinfo \
    $(use_enable 'debug') \
    $(use_with 'lua') \
    $(usev 'xmlrpc' --with-xmlrpc-c) \
    $(usev 'tinyxml2' --with-xmlrpc-tinyxml2) \
    $(usex 'lua' -I$(lua_get_include_dir) ) \
    --with-ncurses \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  use 'doc' && doman doc/rtorrent.1

  # lua file is installed then in the proper directory
  rm "${ED}"/usr/share/rtorrent/lua/rtorrent.lua || die
  if use 'lua'; then
    insinto $(lua_get_lmod_dir)
    doins lua/${PN}.lua
  else
    rm -v -r -- "${ED}"/usr/share/${PN}/lua/ "${ED}"/usr/
  fi

  newinitd "${FILESDIR}/rtorrent-r1.init" rtorrent
  newconfd "${FILESDIR}/rtorrentd.conf" rtorrent
}

pkg_postinst() {
  einfo "This release could introduce new commands to configure RTorrent."
  einfo "Please read the release notes before restarting:"
  einfo "https://github.com/rakshasa/rtorrent/releases"
  einfo ""
  einfo "For configuration assistance, see:"
  einfo "https://github.com/rakshasa/rtorrent/wiki"
}
