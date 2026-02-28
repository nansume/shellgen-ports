#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-24 14:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/parona-overlay/dev-vcs/gcli/gcli-2.10.0.ebuild

EAPI=8

inherit install-functions _autotools _flag-o-matic _toolchain-funcs

DESCRIPTION="Portable CLI tool for interacting with Git(Hub|Lab|Tea) from the command line."
HOMEPAGE="https://herrhotzenplotz.de/gcli/"
LICENSE="BSD-2 Unlicense"
PN="gcli"
PV="2.10.0"
SRC_URI="https://herrhotzenplotz.de/gcli/releases/gcli-${PV}/gcli-${PV}.tar.xz"
IUSE="+libedit -lowdown -test +static -shared -doc (+musl) +stest +strip"
TARGET_INST=

pkgins() { pkginst \
  "#app-text/lowdown  # +lowdown" \
  "dev-libs/gmp  # deps curl" \
  "dev-libs/libedit" \
  "dev-libs/openssl3" \
  "dev-util/byacc  # alternative a bison (posix)" \
  "dev-util/pkgconf" \
  "net-dns/c-ares  # deps curl" \
  "net-misc/curl8-2  # curl[openssl]" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/lex  # alternative a flex (posix)" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/ncurses  # deps libedit" \
  "sys-libs/queue-standalone" \
  "sys-libs/zlib  # deps curl" \
  || die "Failed install build pkg depend... error"
}

src_configure() {
  REALPATH="realpath" \
  INSTALL="install" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    $(usev !libedit --disable-libedit) \
    $(usev libedit --disable-libreadline) \
    $(usev !lowdown --disable-liblowdown) \
    $(usev !test --disable-tests) \
    || die "configure... error"

  sed \
    -e '/^LIBCURL_LIBS=/ s|=.*|= -lcurl -lcares -lssl -lcrypto -lz|' \
    -e '/^LIBEDIT_LIBS_1=/ s|=.*|= -ledit -lncurses -ltinfo|' \
    -i Makefile
}

src_install() {
  make DESTDIR="${ED}" install || die "make install... error"
}
