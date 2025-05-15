#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-05 10:00 UTC - fix: near to compat-posix
# Date: 2024-10-09 17:00 UTC - last change

#local IFS=${NL}

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

printf %s\\n "NL='${NL}'"
printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'" "CFLAGS='${CFLAGS}'"
printf %s\\n "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'" "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'"
printf %s\\n "MAKE='${MAKE}'"

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

test -e 'conf-cc' && printf %s\\n "${CC:?} ${CFLAGS}" > conf-cc
test -e 'conf-ld' && printf %s\\n "${CC:?} ${LDFLAGS}" > conf-ld

if test -e 'configure'; then
  #test -n "${CC}" || { local CC="true"; export CC ;}  # Uncomment for fix <configure> check <compiler>!
  chmod +x 'configure'  # fix unpack from zip
  . runverb ./configure ${MYCONF} || exit
elif test -x 'Configure'; then
  . runverb ./Configure ${DCONF} || exit
elif test -x 'bootstrap.sh'; then
  . runverb ./bootstrap.sh ${MYCONF} || exit
fi
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'

printf %s\\n "Configure directory: ${PWD}/... ok"
