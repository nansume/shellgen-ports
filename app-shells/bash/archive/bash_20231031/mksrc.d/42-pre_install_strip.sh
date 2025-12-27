#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 08:00 UTC - fix: near to compat-posix

local XLIB='libfakeroot.so'; local MAKEFLAGS=${MAKEFLAGS}

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

use 'strip' || return 0

MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})

XLIB=$(findlib ${XLIB}) || exit
XLIB=${XLIB##*/}

printf %s\\n "${MAKEFLAGS} DESTDIR=${INSTALL_DIR} install-strip"
printf %s\\n "deprecated... error"
#exit 1

#make ${MAKEFLAGS} DESTDIR="${INSTALL_DIR}" install-strip

LD_PRELOAD=${XLIB} make ${MAKEFLAGS} install-strip || exit
