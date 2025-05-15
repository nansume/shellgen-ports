#!/bin/bash
# Copyright (C) 2021 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# http://gnu.org/licenses/gpl.html


((UID)) || return 0

cd ${WORKDIR}/
[[ -f './configure' ]] && return

#ACLOCAL= './autogen.sh'
ACLOCAL= 'autoreconf'