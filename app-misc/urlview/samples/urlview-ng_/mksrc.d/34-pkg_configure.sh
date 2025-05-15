#!/bin/sh

EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}


test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed \
  -e '/^VERSION ?=/ s/?=.*/?= 1.0e/' \
  -e '/^SOURCE_DATE_EPOCH ?=/ s/?=.*/?= 202410201703/' \
  -e '/^CXXFLAGS +=/ s/-std=c++2b/c++2a/' \
  -i Makefile

make DESTDIR="${ED}" install || die "make install... error"

rm -- Makefile
