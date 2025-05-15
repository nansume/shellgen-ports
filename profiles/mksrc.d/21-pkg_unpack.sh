#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-08 17:00 UTC - fix: near to compat-posix, no-posix: local VAR, ${RANDOM}
# Date: 2024-10-06 19:00 UTC - last change

local NL="$(printf '\n\t')"; NL=${NL%?}; local IFS=${NL}; local PDIR=${PDIR%/}
local URANDOM; local TMPDIR; local LIST; local ZCOMP; local EXTF; local UDIR; local F; local X; local D

URANDOM=$(tr -dc '0-9' < /dev/urandom | fold -w 5 | head -n 1)
URANDOM="${URANDOM#${URANDOM%%[!0]*}}"
TMPDIR="/tmp/${PKGNAME}${URANDOM}-tmp"
S=${S:-$WORKDIR}  # it dir for unpack src archive. e.g: <workdir>/<srcdir>
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

[ "${S-unset}" != unset ] || return 0  # 2025.04.18 - TODO: probably must return 1
[ -d "${S}" ] || return 0              # 2025.04.18 - TODO: probably must return 1

test -d "${DISTSOURCE}" || return 0
cd "${DISTSOURCE}/"

test "X${USER}" != 'Xroot' && USE_BUILD_ROOT='0'
printf %s\\n "USER='${USER}'" "USE_BUILD_ROOT='${USE_BUILD_ROOT}'"

test "X${USER}" = 'Xroot' && return

cpuonline '1'

test -e "${S}/${PKGNAME}-src" && rm -r -- "${S}/${PKGNAME}-src"
# Unpack (local)
mkdir -pm 0755 -- "${S}/" "${TMPDIR}/"

cd "${S}/"

test -f "${PDIR}/src_uri.lst" &&

#set -o xtrace &&
while IFS= read -r F; do
  F=${F%%#*}
  F="${F%${F##*[![:blank:]]}}"

  case ${F} in
    'file://'*)
      test -n "${BUILD_DIR}" && F="${F//'${BUILD_DIR}'/${BUILD_DIR#/}}"  # no posix
      F="/${F#*://}"  # it local file
    ;;
    *)
      F=${F##*[/ ]}  # support rename: xxx.<ext> -> yyy.<ext>
      F="${DISTSOURCE}/${F}"
    ;;
  esac

  F=${F%\?id=*}  # 2025.04.18 - FIX: remove in filename a hash/commit - match1
  F=${F%\?h=*}  # 2025.04.18 - FIX: remove in filename a hash/commit - match2
  test -n "${F}" || continue

  F=$(vsrcname ${F}) || { printf %s\\n "vsrcname: ${F}... error"; exit 1;}
  test -e "${F}" || { printf %s\\n "file: ${F} not found... error"; exit 1;}

  ZCOMP=
  EXTF=${F##*.}
  #[!.]*/[!.]*.?(t|tar.)+(bz2|bz|gz|lzma|zip|xz)
  #case ${EXTF#t} in
  case ${EXTF} in
    'bz2'|'bz'|'tbz2')
      ZCOMP=$(type 'bunzip2' 'bzip2' 2>/dev/null)
    ;;
    'gz'|'tgz')
      ZCOMP=$(type 'gunzip' 'gzip' 2>/dev/null)
    ;;
    'lz'|'tlz')
      # Lzip - LZMA lossless data compressor
      # https://www.nongnu.org/lzip/lzip.html
      ZCOMP=$(type 'lzip' 2>/dev/null)
      ZCOMP="plzip"
    ;;
    'lzma'|'xz'|'txz')
      ZCOMP=$(type "un${EXTF}" "${EXTF}" "unxz" "xz")
    ;;
    'zip'|'oxt')
      ZCOMP="un${EXTF}"
      ZCOMP="unzip"  # FIX: for `*.oxt` files.
    ;;
    'tar')
      ZCOMP=":"
    ;;
    #'patch'|'diff')  # 2025.04.19 - TODO: it uncomment when to take.
    #  continue
    #;;
    *)
      [ -e "${S}/${PKGNAME}-src/${F#${S}/${PKGNAME}-src/}" ] &&
        { printf %s\\n "file: ${F} exists... error"; continue;}

      [ -d "${S}/${PKGNAME}-src" ] || mkdir -m 0755 -- "${S}/${PKGNAME}-src/"
      cp -n "${F}" -t "${S}/${PKGNAME}-src/"
      continue
    ;;
  esac
  ZCOMP=${ZCOMP%%[[:cntrl:]]*}
  ZCOMP=${ZCOMP##* }
  ZCOMP=${ZCOMP##*/}
  : ${ZCOMP:?}

  printf %s\\n "F='${F}'" "EXTF='${EXTF}'" "ZCOMP='${ZCOMP}'"

  cd "${TMPDIR}/"
  # in busybox for ${ZCOMP} (unpack) opt: <-d> no needed -- only for compat
  case ${F} in
    *'.tar')
      printf %s\\n "tar -xkf ${F}"
      tar -xkf ${F}
    ;;
    *".tar.${EXTF}"|*".t${EXTF#t}")
      printf %s\\n "+ ${ZCOMP} -dc ${F} | tar -xkf -"
      # | tar -x --skip-old-files
      ${ZCOMP} -dc "${F}" | tar -xkf -
    ;;
    *'.zip'|*'.oxt')
      printf %s "+ unzip -q ${F}"
      #unzip -q -d ${PWD}/${PKGNAME}-src/ ${F}
      unzip -q "${F}" || printf %s\\n "... error" &&  # test - fix: unpack double deep rcv. dir
      printf %s\\n "... ok"
      # what unpack one zip file, after bugfix?
    ;;
    *".${EXTF}")
      printf %s\\n "+ ${ZCOMP} -dk ${F}"
      test -f "${F%.*}" || ${ZCOMP} -dk "${F}"
      continue
    ;;
  esac

  LIST=
  for X in */; do test -d "${X%/}" && LIST="${LIST:+${LIST}${NL}}${X}"; done
  #test -n "${LIST}" ||  # 2025.04.16 - FIX: for unpack (zip) into root dir against files and dirs.
  for X in *; do { test ! -d "${X}" && test -e "${X}" ;} && LIST="${LIST:+${LIST}${NL}}${X}"; done
  printf %s\\n "LIST=${LIST}"

  test -n "${LIST-}" || continue

  ################################################
  UDIR=
  test -f "${PDIR}/unpackdir.lst" &&
  while IFS= read -r UDIR; do
    UDIR=${UDIR%/}
    test -n "${UDIR%%[# ]*}" || { UDIR=; continue;}
    test "x${PF##*[/ ]}" = "x${F##*/}" && { UDIR=; continue;}
    test "x${UDIR%% *}" = "x${F##*/}" || { UDIR=; continue;}
    UDIR=${UDIR##*[/ ]}
    case "${UDIR}" in [./]) UDIR=; continue;; esac
    UDIR=${UDIR%.$EXTF}
    UDIR=${UDIR%.tar}
    UDIR="${PKGNAME}-src/${UDIR}"
    break
  done < "${PDIR}/unpackdir.lst"
  test -n "${UDIR}" || UDIR="${PKGNAME}-src"
  printf %s\\n "UDIR='${UDIR}'"
  ################################################

  if case ${LIST} in *${NL}*);; *)! true;; esac; then
    #for D in *; do
    mkdir -pm 0755 "${S}/${UDIR}/"
    #set -o xtrace
    cp -ulr * "${S}/${UDIR}/"
    rm -rf -- *
    { set +o 'xtrace';} >/dev/null 2>&1
  elif test "x${UDIR}" = "x${PKGNAME}-src"; then
    #GLOBIGNORE=${PKGNAME}-src/*
    for D in */*; do
      mkdir -pm 0755 "${S}/${UDIR}/"
      #set -o xtrace
      cp -ulr */* "${S}/${UDIR}/"
      #mv -n */* ${PKGNAME}-src/
      rm -rf -- */
      { set +o 'xtrace';} >/dev/null 2>&1
      continue 2
    done
  else
    mkdir -pm 0755 "${S}/${UDIR}/"
    #set -o xtrace
    cp -ulr */* "${S}/${UDIR}/"
    rm -rf */
    { set +o 'xtrace';} >/dev/null 2>&1
  fi
done < "${PDIR}/src_uri.lst" &&

{ set +o 'xtrace';} >/dev/null 2>&1 &&

cd "${PDIR}/" &&

rmdir "${TMPDIR}/" && printf %s\\n "rmdir ${TMPDIR}/"

WORKDIR="${PDIR%/}/${SRC_DIR}/${PKGNAME}-src"
#WORKDIR="$(SRC_DIR=${SRC_DIR} PKGNAME=${PKGNAME} builddir ${WORKDIR-} || true)"

test -d "${WORKDIR}" || WORKDIR="${PDIR%/}/${SRC_DIR}"

export BUILD_DIR=${BUILD_DIR:-$WORKDIR}
