#!/bin/sh

NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

local IFS="${NL} " IFS="$(printf '\n\t') "
unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

make -j1 \
  DESTDIR="${ED}" \
  LIBDIR="/$(get_libdir)" \
  T="${ED}" \
  CC="${CC}" \
  LDFLAGS="${LDFLAGS}" \
  EXTRA_LDFLAGS="${LDFLAGS}" \
  READLINE_LIB="-lreadline -lhistory -ltinfo -lncurses" \
  calc-static-only BLD_TYPE="calc-static-only" \
  install || die "Failed make build"

rm -- Makefile*