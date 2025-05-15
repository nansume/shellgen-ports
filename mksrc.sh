#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix, no-posix: header file <<!/bin/bash>>, getent

NL="$(printf '\n\t')"; NL=${NL%?}

MKSRCDIR='mksrc.d' SKIPLIST= CDPHASEUSER= P=

: ${USER:=root} ${USE_BUILD_ROOT:=1} ${BUILD_CHROOT:=0} ${PORTS_TMPDIR:=../..}

export USER BUILDLIST XPN

if test "x${USER}" != 'xroot'; then
  ABI_BUILD=${1} LIBDIR=${2} LIB_DIR=${3} PDIR=${4} XPWD=${5} XPN=${6}
  BUILD_CHROOT=${7} _ENV=${8} USE_BUILD_ROOT=${9} BUILDLIST=${10} CATEGORY=${11} PN=${12}
  PWD=${PWD%/}
  test "${BUILD_CHROOT:=0}" -ne '0' || cd ${XPWD%/}/
  getent hosts --service=dns 'localhost' &&
  { printf %s\\n "network: work... error"; exit 1;}
  #. ${ENV:?}
elif test ! -x 'mksrc.sh'; then
  printf '\n\n\n\n######################################\n' >> /var/log/mksrc.log
  # early exist is: SKIPLIST
  printf %s\\n "cp -ur ${PORTS_TMPDIR}/'mksrc.sh' ${PORTS_TMPDIR}/profiles/* ."
  cp -ur ${PORTS_TMPDIR}/'mksrc.sh' ${PORTS_TMPDIR}/profiles/* .
  # test: replace from in old [pre <cp> copy] --> is
  test -s 'removelist.lst' &&
  {
    while IFS= read -r X; do
      SKIPLIST="${SKIPLIST:+${SKIPLIST}${NL}}${X%%#*}"
    done < 'removelist.lst'
    # may be bug to such as: clean located is file: `&>>` =- `>`
    for P in ${SKIPLIST}; do >"${P:=.skip}"; done
  }
fi

sfunc(){
  local SCNAME=${1}; local F
  case ${1} in *'/mksrc.d/'*) printf "\e[1;32m +\e[0;36m ${1}\e[m... \e[0;33mrun\e[m\n";; esac
  . ${@} || return
}

printf %s\\n "PWD='${PWD}'" "USER='${USER}'" "MKSRCDIR='${MKSRCDIR}'"

test "0${BUILD_CHROOT}" -ne '0' || {
  if test -s 'pkgbuild.lst'; then
    while IFS= read -r X; do
      BUILDLIST="${BUILDLIST:+${BUILDLIST} }${X%%#*}"
    done < "pkgbuild.lst"
  fi
  BUILDLIST="${BUILDLIST:+${BUILDLIST} }"
  test -n "${BUILDLIST}" || BUILDLIST=" "
}
printf %s\\n "BUILDLIST='${BUILDLIST}'"

while { test -n "${BUILDLIST}" || test "0${BUILD_CHROOT}" -ne '0' ;} ;do
  if test "0${BUILD_CHROOT}" -ne '0'; then
    XPN=${XPN:-$PN}
  elif test -n "${BUILDLIST## }"; then
    XPN=${BUILDLIST%%[[:cntrl:][:space:]]*}; BUILDLIST=${BUILDLIST#*[[:cntrl:][:space:]]}
    test -n "${XPWD}" && cd ${XPWD%/}/
  fi
  BUILDLIST=${BUILDLIST## }
  printf %s\\n "BUILD_CHROOT='${BUILD_CHROOT}'" "BUILDLIST='${BUILDLIST}'"
  printf %s\\n "XPN='${XPN}'" "USER='${USER}'" "PWD='${PWD}'"
  for F in ${PWD%/}"/${MKSRCDIR}/"*; do
    case ${F} in *'.sh'|*'.env') ;; *) continue;; esac
    if type "buildphase" > /dev/null 2>&1; then
      SCNAME=${F} F=$(buildphase "${CATEGORY}:${PN:-$XPN}:${USER}:${BUILD_CHROOT:-0}:${F}") ||
      { printf %s\\n "buildphase ${CATEGORY}:${PN:-$XPN}:${USER}:${BUILD_CHROOT:-0}:${SCNAME##*/}... skip"; continue;}
    fi
    test -f "${F}" &&
    case ${F} in
      *'.sh')
        sfunc ${F} ${@} || continue
      ;;
      *)
        . ${F} ${@} || continue
      ;;
    esac
  done
  test "0${BUILD_CHROOT}" -ne '0' && break
done
