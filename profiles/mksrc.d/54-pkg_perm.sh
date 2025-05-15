#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 08:00 UTC - fix: near to compat-posix, no-posix: local VAR

local F

(test x"${USER}" != x'root' || test ${BUILD_CHROOT:=0} -ne '0') && return

test -d "${INSTALL_DIR}" || return

for F in *'checksums.lst'; do
  test -e "${F}" || continue
  test -O "${F}" || chown root:root ${F}
done
for F in "${INSTALL_DIR}/"* "${SRC_DIR}/"*; do
  test -e "${F}" && chown -hR root:root ${F}
done

test -d "${DISTSOURCE}" || return 0

cd ${DISTSOURCE}/

for F in *'.'*; do
  case ${F} in 'mksrc.d'|*'.lst'|*'.sh'|*'.sed') continue;; esac
  test -e "${F}" || continue
  test -O "${F}" || chown root:root ${F}
done
