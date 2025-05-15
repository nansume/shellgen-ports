#!/bin/sh
# simple test

ED=${INSTALL_DIR}

local LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
local F

test -d "${ED}" || return

use 'stest' || return 0

cd "${ED}/" || die "install dir: not found... error"

if test "X${USER}" != 'Xroot'; then

  if use 'static'; then
    LD_LIBRARY_PATH=
  else
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  fi
  #printf %s\n LD_LIBRARY_PATH=${LD_LIBRARY_PATH}

  for F in "bin/"* "sbin/"*; do
    test -e "${F}" || continue
    testelf ${F} || continue
    printf %s\\n "${F} --version"
    "${F}" --version || true
    break
  done

  if use !diet;then
    for F in "bin/"* "sbin/"*; do
      test -e "${F}" || continue
      testelf ${F} || continue
      ldd "${F}" || { use 'static' && true;}
      break
    done
  fi

elif test "${BUILD_CHROOT:=0}" -eq '0' && use 'diet';then

  for F in "bin/"* "sbin/"*; do
    test -e "${F}" || continue
    testelf ${F} || continue
    ldd "${F}" || { use 'static' && true;}
    break
  done

fi