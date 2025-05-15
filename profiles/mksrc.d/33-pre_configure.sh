#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 08:00 UTC - fix: near to compat-posix, no-posix: local VAR

export BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local F

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return 0
cd "${BUILD_DIR}/"

for F in [Cc]'onfigure' 'GNUmakefile'; do
  test -x "${F}" && return
done
if test -f 'configure.in'; then
  cp -nl 'configure'.in 'configure'.ac
  rm -- 'configure'.in
  printf %s\\n 'mv -n configure.in configure.ac'
fi
test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

if test -x 'autogen.sh' && test ! -x '/bin/cmake'; then
  ./autogen.sh
  printf %s\\n './autogen.sh'
elif test -f 'GNUmakefile.in'; then
  autoheader
  autoconf
  printf %s\\n 'autoheader && autoconf'
elif test -f 'configure.ac' && test ! -x '/bin/cmake'; then
  # test
  #autoupdate --force  # required for instance to: fontforge-20190801.tar.gz
  F=
  for F in *'/ltmain.sh'; do test -e "${F}" || F=; break; done  # dir: build-aux, auto, etc
  ##########################################################################
  if { test -n "${F}" || test -d 'build-aux' || test -d 'build-scripts' || test -f 'ltmain.sh' ;} ;then
  	autoreconf -f  # test: -f
  	printf %s\\n 'autoreconf -f'
 	else
 	  # fix:  error: required directory ./build-aux does not exist
 		autoreconf -fi  # force install: build-aux/ dir
 		printf %s\\n 'autoreconf -fi'
  fi
elif { test -f 'CMakeLists.txt' && type 'cmake' >/dev/null 2>&1 ;} ;then
  # cmake configure
  case ${BUILD_DIR} in
    *'/build');;
    *)
      BUILD_DIR="${WORKDIR}/build"
      mkdir -p build
      cd build/
    ;;
  esac
  printf %s\\n "cmake ${CMAKEFLAGS} .."
  cmake ${CMAKEFLAGS} ..
elif { test -f 'meson.build' && type 'meson' >/dev/null 2>&1 ;} ;then
  BUILD_DIR="${WORKDIR}/build"
  printf %s\\n "meson setup \${MESON_FLAGS} build"
  meson setup ${MESON_FLAGS} build
fi
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
