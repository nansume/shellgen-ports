#!/bin/sh
# Copyright (C) 2022-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-08 13:00 UTC - fix: near to compat-posix, no-posix: local VAR

local F
local GLOBIGNORE
#local WORKDIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || return
#trap trap - RETURN; shopt -u globstar nullglob extglob' RETURN

# for python and etc.
{ test -x "/bin/make" || test -n "${MAKE}" ;} || return 0

cd ${WORKDIR}/
#shopt -s globstar nullglob extglob

#MAKEFILE=Makefile
# add: GNUmakefile - fix fbida - test, setup.py - python[23]
#GLOBIGNORE="!(GNUmakefile|+(M|m)akefile?(.am|.in|.PL)|+(C|c)onfigure|setup.py)
for F in *; do
  test -e "${F}" &&
  case ${F} in
    GNUmakefile|[Mm]akefile|[Mm]akefile.am|[Mm]akefile.in|[Mm]akefile.PL|[Cc]onfigure|setup.py)
    return;;
  esac
done
#GLOBIGNORE="!(+(*/)+(M|m)akefile.linux*|*(U|u)nix/+(M|m)akefile*|+(*/)+(M|m)akefile*)

for F in */* */*/* */*/*/* */*/*/*/* */*/*/*/*/*; do  # sort fix - test
  test -e "${F}" || continue
  # no-Unix drop: .win .msc .bcb(borland)
  case ${F} in
    *'.win'*|*'.msc'*|*'.bcb'*) continue;;
    */[Mm]akefile.linux*|*[Uu]nix/[Mm]akefile*|*/[Mm]akefile*);;
    *) continue;;
  esac
  WORKDIR="${WORKDIR}/${F%/*}"

  case ${WORKDIR} in
    *'/unix')
      WORKDIR=${WORKDIR%/unix}
      # fix: unzip build: make -f unix/Makefile #test
      XMKFILE="unix/${F##*/}"
      MAKEFILE=${XMKFILE}
    ;;
    *)
      XMKFILE=${F##*/}
      MAKEFILE=${XMKFILE}
    ;;
  esac
  case ${XMKFILE} in *'.am'|*'.in') XMKFILE=${XMKFILE%.*};; esac
  MAKEFILE=${XMKFILE}
  MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}-f ${MAKEFILE}"
  break
done

printf %s\\n "WORKDIR='${WORKDIR}'"
