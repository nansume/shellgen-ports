#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools install-functions

DESCRIPTION="A curses URL parser for text files"
HOMEPAGE="https://packages.qa.debian.org/u/urlview.html"
LICENSE="GPL-2+"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}


test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

patch -p1 -E < "patches/debian.patch"
patch -p1 -E < "patches/Fix-warning-about-implicit-declaration-of-function.patch"
patch -p1 -E < "patches/invoke-AM_INIT_AUTOMAKE-with-foreign.patch"
patch -p1 -E < "patches/Link-against-libncursesw-setlocale-LC_ALL.patch"
patch -p1 -E < "patches/Allow-dumping-URLs-to-stdout.patch"

autoreconf --install
automake

LIBS="-ltinfo" \
./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

dodir "/usr/share/man/man1"
make DESTDIR="${ED}" mandir="${ED}/usr/share/man/" install || die "make install... error"

rm -- Makefile
