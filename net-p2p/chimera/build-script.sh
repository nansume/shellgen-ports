#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Chimera, a light-weight & efficient implementation of a structured
# Homepage: http://current.cs.ucsb.edu/projects/chimera/index.html
# License: GPL-2
# Depends: <deps>
# Date: 2026-02-11 15:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# portage/net-p2p/chimera-1.20.ebuild

PN="chimera"
PV="1.20"  # 2006.06.22
SRC_URI="https://sites.cs.ucsb.edu/~ravenben/chimera/download/${PN}-${PV}.tar.gz"
IUSE="+static +static-libs -shared -doc (+musl) +stest +strip"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}"
PROG="bin/${PN}-sender"

pkgins(){ pkginst \
  "dev-libs/gmp  # deps openssl" \
  "dev-libs/openssl0" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps openssl" \
  || die "Failed install build pkg depend... error"
}

build(){
  # FIX: for build against musl libc
  sed -e 's|extern FILE \*stdin;||' -i src/log.c
  sed -e '/#include <stdio.h>/a #include <pthread.h>/' -i test/*.c

  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  for BIN in "${ED}"/bin/*; do
    mv -v -n ${BIN} ${BIN%/*}/${PN}-${BIN##*/}
  done
}
