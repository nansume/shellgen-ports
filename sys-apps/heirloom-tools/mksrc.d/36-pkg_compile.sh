#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit flag-o-matic readme.gentoo-r1 toolchain-funcs install-functions

DESCRIPTION="Heirloom toolchest - original Unix tools"
HOMEPAGE="https://heirloom.sourceforge.net/tools.html"
LICENSE="ZLIB BSD BSD-4 CDDL GPL-2+ LGPL-2.1+ LPL-1.02 Info-ZIP public-domain"
IUSE="-ncurses -zlib"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed -i "s:\bar\b:ar:g" libwchar/Makefile.mk || die

sed \
  -e 's| cpio csplit | |;s| dd | |;s| diff | |;s| df | |;s|\tfactor ||;s| ls | |' \
  -e 's| more | |;s|\tnawk ||;s| oawk | |;s| pg | |;s|\tsdiff ||;s|\ttabs ||;s| tar | |;s|\tul ||' \
  -e '/^DIETFLAGS/s:CC=.*$:CC="$(CC)" \\:' \
  -e '/$(MAKE)/s: $(DIETFLAGS)::' \
  -i makefile || die

MAKEFLAGS="DEFBIN=${EPREFIX}/bin"
MAKEFLAGS="${MAKEFLAGS} SV3BIN=${EPREFIX}/bin"
MAKEFLAGS="${MAKEFLAGS} S42BIN=${EPREFIX}/$(get_libdir)/${PN}/5bin/s42"
MAKEFLAGS="${MAKEFLAGS} SUSBIN=${EPREFIX}/$(get_libdir)/${PN}/5bin/posix"
MAKEFLAGS="${MAKEFLAGS} SU3BIN=${EPREFIX}/$(get_libdir)/${PN}/5bin/posix2001"
MAKEFLAGS="${MAKEFLAGS} UCBBIN=${EPREFIX}/$(get_libdir)/${PN}/ucb"
MAKEFLAGS="${MAKEFLAGS} CCSBIN=${EPREFIX}/bin"
MAKEFLAGS="${MAKEFLAGS} DEFLIB=${EPREFIX}/$(get_libdir)/${PN}/5lib"
MAKEFLAGS="${MAKEFLAGS} DEFSBIN=${EPREFIX}/bin"
MAKEFLAGS="${MAKEFLAGS} MANDIR=${EPREFIX}/usr/share/man/5man"
MAKEFLAGS="${MAKEFLAGS} DFLDIR=${EPREFIX}/etc/default"
MAKEFLAGS="${MAKEFLAGS} SPELLHIST=/dev/null"
MAKEFLAGS="${MAKEFLAGS} SULOG=${EPREFIX}/var/log/sulog"

append-cppflags -D_GNU_SOURCE

make -j1 \
  CC="${CC}" \
  AR="ar" \
  RANLIB="ranlib" \
  CFLAGS="${CFLAGS}" \
  CFLAGS2="${CFLAGS}" \
  CFLAGSS="${CFLAGS}" \
  CFLAGSU="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  IWCHAR="-I../libwchar" \
  LWCHAR="-L../libwchar -lwchar" \
  LCURS="$(use ncurses && pkgconf --libs curses)" \
  LDFLAGS="${LDFLAGS}" \
  USE_ZLIB=$(usex 'zlib' 1 0) \
  $(usex !zlib "LIBZ=") \
  $(usex 'diet' diet) \
  ${MAKEFLAGS} \
  || die "Failed make build"

make -j1 \
  ROOT="${ED}" \
  TTYGRP= \
  ${MAKEFLAGS} \
  $(usex 'diet' dietinstall install) \
  || die "make install... error"

rm -r -- "${ED}"/dev/ "${ED}"/var/ || true
dodoc CHANGES README

unset MAKEFLAGS
rm -- Makefile makefile

cd "${ED}/" || return
mv -f "$(get_libdir)/${PN}/ucb/"basename -t "bin/"
mv -f "$(get_libdir)/${PN}/ucb/"install -t "bin/"
#mv -f "$(get_libdir)/${PN}/ucb/"ln -t "bin/"

mv -f "$(get_libdir)/${PN}/5bin/posix/"egrep -t "bin/"
mv -f "$(get_libdir)/${PN}/5bin/posix/"fgrep -t "bin/"
mv -f "$(get_libdir)/${PN}/5bin/posix/"getconf -t "bin/"
#mv -f "$(get_libdir)/${PN}/5bin/posix/"grep -t "bin/"
mv -f "$(get_libdir)/${PN}/5bin/posix/"rmdir -t "bin/"

cd "${ED}/$(get_libdir)/${PN}/" || return
rm -r -- "ucb/" "5bin/"

cd "${ED}/" || return
rm -- bin/awk

printf %s\\n "Install: ${PN}"
