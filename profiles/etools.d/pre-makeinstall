#!/bin/sh
# Copyright (C) 2023-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-06 20:00 UTC - fix: near to compat-posix, no-posix: local VAR

local MK

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

# fix add support: Makefile.no-imake - pkg: <9wm>
for MK in *; do
  test -f "${MK}" &&
  case ${MK} in [Mm]akefile.*|[Mm]akefile|GNUmakefile|${XMKFILE:-makefile}) break;; esac
  MK=
done
test -n "${MK}" || return 0

for MK in *; do
  test -f "${MK}" && case ${MK} in *'.am'|*'.in'|*'.win'*|*'.msc'*|*'.bcb'*);; *) break;; esac
  MK=
done
test -n "${MK}" || return 0

test -n "${MAKEFLAGS}" || return 0  # fixbug: mapsetre: line 5: 3: required mapset

# error PREFIX= prefix=: cdrkit install - install/install/
#MAKEINSTALL+=" PREFIX=${SPREFIX%/}/${INSTALL_DIR#/}
#MAKEINSTALL+=" prefix=${SPREFIX%/}/${INSTALL_DIR#/}
MAKEFLAGS=$(printf %s " ${MAKEFLAGS} " | sed "s| PREFIX=[^ ]* | PREFIX=${SPREFIX%/} |")  # fix: pkg <dmenu>
MAKEFLAGS=$(mapsetre 'prefix=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(printf %s "${MAKEFLAGS}" | sed "s| USRDIR=[^ ]* | USRDIR=${SPREFIX%/}/${INSTALL_DIR#/} |")
MAKEFLAGS=$(printf %s "${MAKEFLAGS}" | sed "s| LIBDIR=[^ ]* | LIBDIR=${LIB_DIR} |;s|^ *||;s| *$||")

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }DESTDIR=${INSTALL_DIR}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }INSTALLROOT=${INSTALL_DIR}"     # extlinux
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }INSTALL_PREFIX=${INSTALL_DIR}"  # ftpproxy
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }BUILDROOT=${INSTALL_DIR}"       # fix: <cupsd> install - <buildroot>
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }LIB=${LIB_DIR}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }LIBPREFIX=${LIBDIR}"            # fix: suckless lib
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }INCPREFIX=${INCDIR}"            # fix: suckless include dir
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }BIN=${INSTALL_DIR}/bin"         # fix: pkg <9wm> (port plan9)
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }DATADIR=/${DPREFIX#/}/share"    # fix: pkg <espeak-ng> - testing
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }MANDIR=${INSTALL_DIR}/${DPREFIX#/}/share/man/man1"  # fix: pkg <9wm>
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }MANPREFIX=${DPREFIX}/share/man"                     # fix: suckless pkg
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }LTLIBRARIES="

MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})  # IFS nl --> space, otherwise no work.

printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
