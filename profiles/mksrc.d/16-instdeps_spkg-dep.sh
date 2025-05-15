#!/bin/sh
# Copyright (C) 2022-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 18:00 UTC - fix: near to compat-posix, no-posix: local VAR
# Date: 2024-10-08 17:00 UTC - last change

export COMPILER="gcc"

local NL="$(printf '\n\t')"; NL=${NL%?}; local IFS=${NL}; local RUN=${!##*_}; local XABI=${ABI}
local PATH="${PATH:+${PATH}:}${PDIR%/}/misc.d"
local ROOT_DIR; local PKGS; local F; local PKG

RUN=${RUN%.sh}
RUN='spkg-dep'
RUN='spkg'  # 2025.04.21 - FIX: bug: appears unnecessary deps

test "X${USER}" != 'Xroot' && return
test "${BUILD_CHROOT:=0}" -eq '0' && return

#X=removelist.lst SKIPLIST=

#test -s "${X} &&
#while IFS= read -r X; do
#  X=${X%%#*}
#  X="${X%${X##*[![:space:]]}}
#  test -n ${X} && SKIPLIST=${SKIPLIST:+${SKIPLIST}${NL}}${X#${X%%[![:space:]]*}}"
#done < ${X}

PKGS=
for F in "${PDIR%/}/build.deps/"* ''; do
  test -e "${F}" || continue
  skiplist "${F#${PDIR%/}/}" && continue
  while IFS= read -r X; do
    X=${X%%#*}
    X="${X%${X##*[![:space:]]}}"
    PKGS="${PKGS:+${PKGS}${NL}}${X#${X%%[![:space:]]*}}"
  done < ${F}
  PKGS="${PKGS:+${PKGS}${NL}}${F##*/}"
done

use 'diet' && { PKGS="${PKGS:+${PKGS}${NL}}dev-libs/dietlibc0"; COMPILER="diet";}
use 'musl' && PKGS="${PKGS:+${PKGS}${NL}}sys-libs/musl"
use 'upx'  && PKGS="${PKGS:+${PKGS}${NL}}app-arch/upx"
              PKGS="${PKGS:+${PKGS}${NL}}sys-apps/musl-utils"

if test "X${ABI}" = 'Xx32'; then
  ABI=${ABI} ROOT_DIR='/' "${RUN}" ${PKGS}
  return
fi

for PKG in ${PKGS}; do
  test -n "${PKG%%#*}" || continue
  XABI=${ABI}
  if ABI=${ABI} pkg-is ${PKG}; then
    :
  else
    XABI="x32"
  fi
  ABI=${XABI} ROOT_DIR='/' "${RUN}" ${PKG}
  testxpath 'unxz' || return 0
done
