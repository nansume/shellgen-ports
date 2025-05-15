#!/bin/sh
# Copyright (C) 2023-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix, no-posix: local VAR
# Date: 2024-10-04 08:00 UTC - last change

local X; local PY

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

# it buildphase: user=root,chroot=1


printf %s\\n "PWD='${PWD}'"

# openssl fix: find lib*.so
for X in /${LIB_DIR}/libcrypto.so.1.* /${LIB_DIR}/libssl.so.1.*; do
  test -e "${X}" && ln -sf ${X%%*/} "${X%${X#*.so}}"
done
# /bin/<python> for python 2 or 3 version
for X in /bin/python[23]; do
  test -e "${X}" && ln -sf ${X%%*/} "${X%[23]}"
done
#Could not find platform dependent libraries <exec_prefix>
#Consider setting $PYTHONHOME to <prefix>[:<exec_prefix>]
#ModuleNotFoundError: No module named <_posixsubprocess>
for X in /${LIB_DIR}/python*/lib-dynload; do
  test -e "${X}" || continue
  PY=${X#?*/}
  ln -sf ../../${X#/} "/lib/${PY%%/*}/"
  # fix: py-unicodedata2 -I/include/python3.6m - error: Python.h: No such file
  ln -sf "/${DPREFIX#/}/include" /
  # for install <py-pkgname>: CPPFLAGS+="-I${INCDIR}
  # -I/usr/include/python3.6m -lpython3.6m
  # $(pkg-config --cflags --libs python3)
  break
done
PYTHONPYCACHEPREFIX=${PYTHONPYCACHEPREFIX:-/var/cache/python}

: ${BUILD_USER:?} ${PYTHONPYCACHEPREFIX:?}
mkdir -m 0755 -- "${PYTHONPYCACHEPREFIX:?}"
chown ${BUILD_USER:?}:${BUILD_USER} "${PYTHONPYCACHEPREFIX}"

# fix: No package <xorg-macros [util-macros]> found
# correct fix: PKG_CONFIG_PATH
for X in /usr/share/pkgconfig/xorg-macros[.]pc; do
  test -f "${X}" || continue
  # correct is: /lib/pkgconfig/
  mkdir -pm 0755 "/${LIB_DIR}/pkgconfig/"
  ln -sf ${X} "/${LIB_DIR}/pkgconfig/"
done

# FIX: replace to: usr/ports/profiles/mksrc.d/28-pre_diet_include.sh
#  and it remove.
if test -x "__/opt/diet/bin/diet" || false use 'diet'; then  # use: not found
  #X="/usr/include/linux/sockios.h"
  #test -f "${X}" && cp -nl ${X} /opt/diet/include/linux/
  #X="/usr/include/linux/fb.h"
  #test -f "${X}" && cp -nl ${X} /opt/diet/include/linux/
  test -f "/usr/include/linux/fb.h" && cp -vnlr /usr/include/linux/* /opt/diet/include/linux/
  #cp -nlr usr/include/asm/*.h opt/diet/include/asm/
  #cp -nlr usr/include/asm-generic opt/diet/include/

  for X in /usr/include/*.h /usr/include/*/; do
    case ${X} in
      *'*'*|*'/c++/') continue
      ;;
      *'/asm-generic/')
        X=${X%/}
        if test -e "${X}" && ! test -e "/opt/diet/include/${X##*/}"; then
          cp -nlr ${X} -t /opt/diet/include/ &&
          cp -nlr ${X}/* -t /opt/diet/include/asm/ &&
          printf %s\\n "cp -vnlr ${X}/* -t /opt/diet/include/asm/"
        fi
      ;;
      *)
        X=${X%/}
        if test -e "${X}" && ! test -e "/opt/diet/include/${X##*/}"; then
          cp -nlr ${X} -t /opt/diet/include/ &&
          printf %s\\n "cp -vnlr ${X} -t /opt/diet/include/"
        fi
      ;;
    esac
  done

  #[ -d "/usr/include/libowfat" ] && cp -v -nl /usr/include/libowfat/*.h -t /opt/diet/include/

fi

X="/bin/musl-gcc"
X="/bin/gcc"
# fix error:  make: cc: No such file or directory
test -x "${X}" && ln -sf ${X##*/} "${X%/*}/cc"

# fix error:  not found: <gcc>
ln -sf '../libx32/libc.so' '/lib/ld-musl-x32.so.1' &&
printf %s\\n "ln -sf ../libx32/libc.so /lib/ld-musl-x32.so.1"

if use !usrlib 2>/dev/null || true; then  # BUG: use: not found
  set -- "usr/lib" "usr/${LIB_DIR}" "usr/libx32" "usr/lib64" "usr/lib32"
  until test -z "${1}"; do
    test -L "${1}" && { rm -- "${1}" && printf %s\\n "rm -- ${1}" ;}
    shift
  done
fi
