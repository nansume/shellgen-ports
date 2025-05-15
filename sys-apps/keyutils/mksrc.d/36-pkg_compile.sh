#!/bin/sh
# -static -staticbin +static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions linux-info multilib-minimal

DESCRIPTION="Linux Key Management Utilities"
HOMEPAGE="https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/keyutils.git"
LICENSE="GPL-2 LGPL-2.1"
IUSE="-staticbin +static-libs -test"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED
local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}; local NO_ARLIB
unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

# The lsb check is useless, so avoid spurious command not found messages.
sed -i -e 's,lsb_release,:,' tests/prepare.inc.sh || die
# Some tests call the kernel which calls userspace, but that will
# run the install keyutils rather than the locally compiled one,
# so disable round trip tests.
rm -rf tests/keyctl/requesting/bad-args tests/keyctl/requesting/piped tests/keyctl/requesting/valid

if use 'staticbin'; then
  NO_ARLIB=0
else
  NO_ARLIB=$(usex 'static-libs' 0 1)
fi
export AR="ar" CC CXX

make V='0' -j"$(nproc)" \
  PREFIX="${EPREFIX}/usr" \
  ETCDIR="${EPREFIX}/etc" \
  BINDIR="${EPREFIX}/bin" \
  SBINDIR="${EPREFIX}/sbin" \
  SHAREDIR="${EPREFIX}/usr/share/keyutils" \
  MANDIR="${EPREFIX}/usr/share/man" \
  INCLUDEDIR="${EPREFIX}/usr/include" \
  LIBDIR="${EPREFIX}/$(get_libdir)" \
  USRLIBDIR="${EPREFIX}/$(get_libdir)" \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  RPATH=$(usex 'staticbin' -static '') \
  BUILDFOR= \
  NO_ARLIB="${NO_ARLIB}" \
  || die "Failed make build"

NO_ARLIB=$(usex 'static-libs' 0 1)

printf %s\\n 'make DESTDIR=${ED} install'
make \
  DESTDIR=${ED} \
  PREFIX="${EPREFIX}/usr" \
  ETCDIR="${EPREFIX}/etc" \
  BINDIR="${EPREFIX}/bin" \
  SBINDIR="${EPREFIX}/sbin" \
  SHAREDIR="${EPREFIX}/usr/share/keyutils" \
  MANDIR="${EPREFIX}/usr/share/man" \
  INCLUDEDIR="${EPREFIX}/usr/include" \
  LIBDIR="${EPREFIX}/$(get_libdir)" \
  USRLIBDIR="${EPREFIX}/$(get_libdir)" \
  NO_ARLIB="${NO_ARLIB}" \
  install \
  || die "make install... error"

dodoc README

rm -- Makefile

printf %s\\n "Install: ${PN}"
