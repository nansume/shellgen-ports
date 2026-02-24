#!/bin/sh
# -static -static-libs -shared -nopie -patch -doc -xstub -diet -musl +stest -strip +noarch +x32

# http://data.gpo.zugaina.org/gentoo/dev-util/mk-configure/mk-configure-0.38.3.ebuild

DESCRIPTION="Lightweight replacement for GNU autotools"
HOMEPAGE="https://sourceforge.net/projects/mk-configure/"
LICENSE="BSD BSD-2 GPL-2+ MIT"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS=${NL}
local MAKEFLAGS=; unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

sed -e "s|=@mkc_libexecdir@|=${ED}/libexec/mk-configure|" -i scripts/mkc_check_prog.in

#runverb ${IONICE_COMM} \
${MAKE} V='0' \
  ${MAKEFLAGS} \
  CC="${CC}" \
  CPP="${CPP}" \
  CXX="g++" \
  DESTDIR=${ED} \
  LDCOMPILER="yes" \
  MKPIE="no" \
  USE_SSP="no" \
  USE_RELRO="no" \
  USE_FORT="no" \
  WARNERR="no" \
  INSTALL="install" \
  INSTALL_FLAGS="" \
  MK_INSTALL_AS_USER="no" \
  INSTALL_AS_USER="no" \
  BINOWN="$(id -nu)" \
  BINGRP="$(id -ng)" \
  MKINSTALL="yes" \
  MKCOMPILERSETTINGS="force" \
  PREFIX='' \
  DOCDIR="/usr/share/doc/${PN}" \
  INFODIR="/usr/share/info" \
  LIBDIR="/$(get_libdir)" \
  MANDIR="/usr/share/man" \
  MKFILESDIR="/usr/share/mk-configure/mk" \
  BUILTINSDIR="/usr/share/mk-configure/builtins" \
  FEATURESDIR="/usr/share/mk-configure/feature" \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  all install \
  || die "Failed make build"

sed -e "s|=/libexec/mk-configure|=/usr/libexec/mk-configure|" -i "${ED}"/bin/*

mv -v "${ED}"/libexec "${ED}"/usr/

rm -- Makefile*
