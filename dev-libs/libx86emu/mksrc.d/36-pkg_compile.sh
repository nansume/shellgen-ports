#!/bin/sh
# -static -static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A library for emulating x86"
HOMEPAGE="https://github.com/wfeldt/libx86emu"
LICENSE="BSD"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "
local MAKEFLAGS=; unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

printf "${PV}" > VERSION || die
rm -r -- git2log || die

${MAKE} -j"$(nproc)" V='0' \
  ${MAKEFLAGS} \
  CC="${CC}" \
  DESTDIR=${ED} \
  prefix='' \
  LIBDIR="/$(get_libdir)" \
  includedir="/usr/include" \
  CFLAGS="${CFLAGS} -fPIC -Wall" \
  LDFLAGS="${LDFLAGS}" \
  shared install \
  || die "Failed make build"

rm -- Makefile
