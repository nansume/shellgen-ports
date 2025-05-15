#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x86

inherit flag-o-matic multilib-build toolchain-funcs install-functions

DESCRIPTION="Statifier is a tool for creating portable, self-containing Linux executables"
HOMEPAGE="http://statifier.sourceforge.net"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
INST_ABI="$(tc-abi-build)"

export PN PV EPREFIX BUILD_DIR ED CC INST_ABI

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# Don't compile 32-bit on amd64 no-multilib profile
if ! use 'x86'; then
  sed -e 's/ELF32 .*/ELF32 := no/g' -i configs/config.x86_64 || die
fi

# Debug flags are known to cause compile failure
filter-flags "-g[0-9]"

# Fix permissions, as configure is not marked executable
chmod +x configure || die

./configure || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

sed -e 's/SUBDIRS  = src man rpm/SUBDIRS  = src man/' -i Makefile
sed \
  -e "/^LIB_DIR / s:\$(DESTDIR)/usr/lib/${PN}:\$(DESTDIR)/lib/${PN}:" \
  -e "/^BIN_DIR / s:\$(DESTDIR)/usr/bin:\$(DESTDIR)/bin:" \
  -i src/Makefile

# Package complains with MAKEOPTS > -j1
make V='0' -j1 || die "Failed make build"

# Package complains with MAKEOPTS > -j1
make -j1 DESTDIR=${ED} install || die "make install... error"

rm -- Makefile*

einstalldocs

printf %s\\n "Install: ${PN}"
