#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit libtool install-functions

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
LICENSE="LGPL-2.1+"
IUSE="+aspell -hunspell -nuspell -test -voikko"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

: elibtoolize

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'test' relocatable) \
  --without-hspell \
  --without-applespell \
  --without-zemberek \
  --with-hunspell-dir="${EPREFIX}"/usr/share/hunspell/ \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make || : die "Failed make build"
make DESTDIR=${ED} install || : die "make install... error"

rm -- Makefile
