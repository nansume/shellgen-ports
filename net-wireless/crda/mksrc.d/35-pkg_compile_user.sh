#!/bin/sh
# it replace for <36-pkg_compile.sh>

PYTHON="true"
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

sed -e "s:\<pkg-config\>:${PKG_CONFIG}:" -i Makefile || die

make -j "$(nproc)" \
  PREFIX="${EPREFIX%/}/usr" \
  SBINDIR='/sbin/' \
  LIBDIR='/'"$(get_libdir)" \
  UDEV_RULE_DIR="/lib/udev/rules.d" \
  REG_BIN="${SYSROOT}"/lib/crda/regulatory.bin \
  USE_OPENSSL=0 \
  CC="${CC}" \
  V=1 \
  WERROR= \
  all_noverify \
  || die "Failed make build"

make DESTDIR="${ED}" install || die "make install... error"

rm -- Makefile

rm -v -r -- "${ED}/usr/share/man/" "${ED}/usr/share/"