#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


MYCONF=(
 --prefix=
 --libdir="/${LIB_DIR}"
 --includedir="${INCDIR}"
 --libexecdir="${DPREFIX}/libexec"
 --datadir="${DPREFIX}/share"
 --host=${CHOST}
 --build=${CHOST}
)