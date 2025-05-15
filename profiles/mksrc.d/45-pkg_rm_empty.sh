#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 16:00 UTC - fix: near to compat-posix, no-posix: local VAR

local NL="$(printf '\n\t')"; NL=${NL%?}; local IFS=${NL}; local LIST; local X; local P

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${INSTALL_DIR}/ || return

LIST=
for X in $(dotglobstar); do test -e "${X}" && LIST="${X}${LIST:+${NL}${LIST}}"; done

for P in ${LIST}; do
  for X in "${P}/"*; do test -e "${X}" && continue 2; done
  if { test -L "${P}" && test -d "${P}" || test -f "${P}"; }; then
    continue
  elif test -L "${P}"; then
    # bug - delete it:  etc/fonts/conf.d/90-synthetic.conf
    printf %s\\n "dry-run: rm -- ${P}" ||:
  elif test -d "${P}"; then
    #set -o xtrace
    rmdir "${P}/" && printf %s\\n "rmdir ${P}/" ||:
    { set +o 'xtrace';} >/dev/null 2>&1
  fi
done
