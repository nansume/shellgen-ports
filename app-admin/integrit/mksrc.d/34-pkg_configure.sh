#!/bin/sh
# +static +static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools install-functions

DESCRIPTION="file integrity verification program"
HOMEPAGE="https://integrit.sourceforge.net/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

mv -n configure.in configure.ac || die "Failed to move configure.in into .ac"
mv -n hashtbl/configure.in hashtbl/configure.ac || die "Failed to move hashtbl/configure.in into .ac"

autoreconf --install
> ar-lib || die  #775746

./configure \
  --prefix="${EPREFIX}" \
  --exec-prefix="${EPREFIX}" \
  --bindir="${EPREFIX}/bin" \
  --sbindir="${EPREFIX}/sbin" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --infodir="${DPREFIX}/share/info" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make
make utils

make -C doc
make -C hashtbl hashtest

rm -- Makefile

dosbin integrit
dolib.a libintegrit.a
dodoc Changes HACKING README todo.txt

# utils
dosbin utils/i-viewdb
dobin utils/i-ls

# hashtbl
dolib.a hashtbl/libhashtbl.a
doheader hashtbl/hashtbl.h
dobin hashtbl/hashtest
newdoc hashtbl/README README.hashtbl

# doc
doman doc/i-ls.1 doc/i-viewdb.1 doc/integrit.1
#doinfo doc/integrit.info

# examples
dodoc -r examples

printf %s\\n "Install: ${PN}"
