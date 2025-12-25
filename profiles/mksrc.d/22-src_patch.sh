#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-12 11:00 UTC, 2025-12-22 19:00 UTC - last change

local EXITCODE='0'
local PDIR=${PDIR}
local F="${PDIR}/src_uri.lst"
local PATCH='patch'
local PATCHES; local P
local BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

export BUILD_DIR="$(SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-} || true)"

PDIR=${PDIR%/}

{ test -x "/bin/g${PATCH}" && test ! -L "/bin/g${PATCH}" ;} && PATCH="/bin/g${PATCH}"
printf %s\\n "PATCH='${PATCH}'"

cd "${BUILD_DIR}/" || return

for P in "${PDIR}/dist-src/"* "${PDIR}/dist-src/".[!.]*; do
  test -e "${P}" && { cp -ulr "${P}" "${BUILD_DIR}/" && printf %s\\n "cp -ulr ${P} ${BUILD_DIR}/" ;}
done

{ use 'patch' || "false" use 'patches' ;} || return 0

test -f "${F}" &&
while IFS= read -r F; do
  F=${F%%#*}
  F="${F%${F##*[![:space:]]}}"
  case ${F} in
    'file://'*)
      test -n "${BUILD_DIR}" && F="${F//'${BUILD_DIR}'/${BUILD_DIR}}"  # no posix
      F="/${F#*://}"
    ;;
    *)
      F="${DISTSOURCE}/${F##*[/ ]}"  # support rename: xxx.patch -> yyy.patch
    ;;
  esac
  test -n "${F}" || continue
  F=$(vsrcname ${F}) || exit
  F=${F%\?id=*}  # 2025.04.18 - FIX: remove in filename a hash/commit - match1
  F=${F%\?h=*}  # 2025.04.18 - FIX: remove in filename a hash/commit - match2
  F=${F%.xz} F=${F%.lzma} F=${F%.gz} F=${F%.bz2} F=${F%.lz}  # it early unpack, as possible to remove
  #case ${F} in *'.patch'*|*'.diff'*);; *) continue;; esac  # 2025.04.18 - TODO: it uncomment.
  printf %s\\n "patch file add: '${F}'"
  test -f "${F}" && PATCHES="${PATCHES}${PATCHES:+ }${F}"
done < ${F}

#PATCHES="${PATCHES#${PATCHES%%[![:space:]]*}}"  # ?FIX, on if needed
#${PATCHES#*[[:space:]]} \  # BUG: in <for> it remove 1 patch file (1-string)

for F in \
    'patches/'* \
    [0-9]*[0-9][-_]*'.patch' \
    [0-9]*[0-9][-_]*'.diff' \
    ${PATCHES} \
    "${PDIR}/patches/"*'.diff'
  do
  case ${F} in *'.patch'|*'.diff');; *) continue;; esac
  test -f "${F}" &&
  case ${F} in *"${ABI}.patch"|*"${ABI}.diff") test "X${ABI}" = 'Xx32' || continue;; esac &&
  if test "X${PATCH}" = 'X/bin/gpatch'; then
    ${PATCH} -p1 -g0 -E --no-backup-if-mismatch < "${F}" &&
    printf "\e[1;32m +\e[0;35m ${F##*/}\e[m... \e[0;36mok\e[m\n" ||
    { EXITCODE='1'; printf "\e[0;36m +\e[0;31m ${F##*/}\e[m: patching... \e[0;31mfailed\e[m\n" >&2 ;}
  else
    ${PATCH} -p1 -E < "${F}" &&
    printf "\e[1;32m +\e[0;35m ${F##*/}\e[m... \e[0;36mok\e[m\n" ||
    { EXITCODE='1'; printf "\e[0;36m +\e[0;31m ${F##*/}\e[m: patching... \e[0;31mfailed\e[m\n" >&2 ;}
  fi
done

return ${EXITCODE}
