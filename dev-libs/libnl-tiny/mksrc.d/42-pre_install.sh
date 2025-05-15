#!/bin/sh

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

MAKEFLAGS="prefix= libdir=/$(get_libdir) includedir=/usr/include"

make DESTDIR='/install' ${MAKEFLAGS} install

sed -i \
  -e "3s|^libdir=.*|libdir=/$(get_libdir)|;t" \
  -e "4s|^includedir=.*|includedir=/usr/include/${PN}|;t" \
  ${ED}/$(get_libdir)/pkgconfig/${PN}.pc
