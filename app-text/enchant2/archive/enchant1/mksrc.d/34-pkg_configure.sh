#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit libtool install-functions

DESCRIPTION="Spellchecker wrapping library"
HOMEPAGE="https://abiword.github.io/enchant/"
LICENSE="LGPL-2.1+"
IUSE="+aspell -hunspell -test"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed -e "s/build_zemberek=yes//" -i configure.ac configure || die  # bug 662484

. runverb \
./configure \
  --prefix="/usr" \
  --exec-prefix="${EPREFIX%/}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --datadir="${EPREFIX%/%/}"/usr/share/enchant-1 \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'aspell') \
  $(use_enable 'hunspell' myspell) \
  --disable-hspell \
  --disable-ispell \
  --disable-uspell \
  --disable-voikko \
  --disable-zemberek \
  --with-aspell-prefix="/usr" \
  --with-myspell-dir="${EPREFIX%/}"/usr/share/myspell/ \
  $(use_enable 'shared') \
  --disable-static \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make || die "Failed make build"
make DESTDIR=${ED} install || die "make install... error"

find "${ED}/$(get_libdir)/" -name '*.la' -delete || die

rm -- Makefile
