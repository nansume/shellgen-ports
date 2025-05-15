#!/bin/sh

local X; local PATH="${PATH:+${PATH}:}${PDIR%/}/misc.d"

#printf %s\n LD_LIBRARY_PATH=${LD_LIBRARY_PATH}
set -- "$(ldpath)"

export LD_LIBRARY_PATH="${1:-${LD_LIBRARY_PATH:?not set: required... error}}"

# bdirlib - required fix to $(bdirlib)
#test "X${USER}" != 'Xroot' && { bdirlib; printf %s\\n "LD_LIBRARY_PATH='${LD_LIBRARY_PATH}'";}

{ test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} || return 0

{ use 'bootstrap' && test -x '/bin/musl-gcc' && test -x '/lib/libc.so' ;} || return 0

for X in /${LIB_DIR}/*; do
  test -d "${X}" && continue
  test -e "/lib/${X##*/}" ||
  { ln -s "${X}" "/lib/${X##*/}" && printf %s\\n "ln -s ${X} -> /lib/${X##*/}";}
done
