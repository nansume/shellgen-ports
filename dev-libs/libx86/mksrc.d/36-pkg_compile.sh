#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A hardware-independent library for executing real-mode x86 code"
HOMEPAGE="https://www.codon.org.uk/~mjg59/libx86/"
LICENSE="BSD"
PV="1.1"
IUSE="-x86 +static-libs +shared +nopie -doc (+musl) +stest +strip"  # BUG: with +x86 no build.
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

append-cflags -fPIC
append-cflags -fno-delete-null-pointer-checks  #523276

${MAKE} -j"$(nproc)" V='0' \
  CC="${CC}" \
  CPP="${CPP}" \
  prefix='' \
  LIBDIR="/$(get_libdir)" \
  includedir="/usr/include" \
  $(usex !x86 BACKEND="x86emu") \
  LIBRARY="shared static" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  shared static \
  || die "Failed make build"

${MAKE} V='0' \
  DESTDIR=${ED} \
  prefix='' \
  LIBDIR="/$(get_libdir)" \
  includedir="/usr/include" \
  install-header install-shared install-static \
  || die "make install... error"

rm -- Makefile
