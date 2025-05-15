#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# Date: 2024-04-01 12:00 UTC - last change
# Date: 2025-05-14 11:00 UTC - last change

export ED=${ED:-$INSTALL_DIR}

local BINDIR
local X

test "X${USER}" != 'Xroot' || return 0

cd ${ED}/ || return

for X in bin/${XPN} sbin/${XPN} bin/${PKGNAME} sbin/${PKGNAME}; do
  BINDIR=${X%/*}
  { test -e "${X}" && test ! -e "${BINDIR}/${PN}" ;} || continue
  mv -n ${X} ${BINDIR}/${PN} && printf %s\\n "mv -vn '${BINDIR}' -> '${BINDIR}/${PN}'"
done

for X in "$(get_libdir)/pkgconfig/"lib*.pc; do
  test -e "${X}" || break
  # https://stackoverflow.com/questions/148451/
  # replace only from 4string to 5string
  sed -i '4,5s|^includedir=//include$|includedir=/usr/include|;t' ${X}
  # TODO: fix: for <includedir=//usr/include>
  #sed -e '/^libdir=/ s|//|/|' -e '/^includedir=/ s|//|/|' -i ${X}
done
