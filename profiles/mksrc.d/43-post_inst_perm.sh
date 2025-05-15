#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 16:00 UTC - fix: near to compat-posix, no-posix: local VAR

local IFS="$(printf '\n\t')"; IFS=${IFS%?}
local P

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' || return 0

test -d "${INSTALL_DIR}" || return 0
cd "${INSTALL_DIR}/"

for P in $(globstar); do
  test -e "${P}" || continue
  test -w "${P}" || test -L "${P}" || {
    #set -o xtrace
    chmod +w ${P} && printf %s\\n "chmod +w ${P}"
    { set +o 'xtrace';} >/dev/null 2>&1
  }
done
