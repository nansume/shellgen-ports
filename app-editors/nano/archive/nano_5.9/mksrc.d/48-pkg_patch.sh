#!/bin/sh
# Copyright (C) 2021 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-15 12:00 UTC - fix: near to compat-posix, no-posix: local VAR

local S
local F

test "x${USER}" != 'xroot' && {
  cd ${INSTALL_DIR}/

  for S in '../'*'.sed'; do
    test -f "${S}" || continue
    set -- '0'
    while IFS= read -r F; do
      set -- $(expr ${1} + '1')
      test "${1}" -ge '2' && break
    done < ${S}

    F=${F#*^}
    sed -i -f "${S}" "${F}" && printf %s\\n "sed -i -f ${S} ${F}... ok"
  done
}
