#!/bin/sh

local DPREFIX=${DPREFIX#/}; local PN=${PN%[23]}; local PY; local H; local X

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

# python build config - header
for H in include/${PN}*/*.h; do
  test -e "${H}" || continue
  PY=${H%/*}
  PY=${PY##*/}
  test -d "${DPREFIX}/include/${PY}" || break
  set -o 'xtrace'
  cp -nl ${H} ${DPREFIX}/include/${PY}/
  rm -- "${H}"
  { set +o 'xtrace';} >/dev/null 2>&1
done
# /bin/<python> for python 2 or 3 version
for X in /bin/python[3]; do
  test -e "${X}" || continue
  ln -sf ${X%%*/} "${X%[23]}"
done
# fix: not find platform dependent libraries <exec_prefix>
for X in ${LIB_DIR}/python*/lib-dynload; do
  test -e "${X}" || continue
  PY=${X#?*/}
  ln -sf ../../${X#/} "lib/${PY%%/*}/"
done
# build config clean - scripts
for X in ${LIB_DIR}/python*/config/*; do
  test -e "${X}" || continue
  rm -- "${X%/*?}/"*
  break
done

# python3 -- pip
test -d "${INSTALL_DIR}/.local" && rm -- ".local/"*
