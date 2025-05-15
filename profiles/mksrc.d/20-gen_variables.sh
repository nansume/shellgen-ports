#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix, no-posix: local VAR

test "X${USER}" != 'Xroot' || return 0

export CBUILD=${CHOST}
export CTARGET=${CHOST}
export PKG_CONFIG="pkgconf"  # testing: fix for x11-wm/musca
export PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
export PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"

# it no work normal, required fix.
CC=$(type 'musl-gcc' 'gcc' 'cc' 2>/dev/null)
CC=$(type 'gcc' 'cc' 2>/dev/null)
CC=${CC#*: not found}
CC=${CC%%[[:cntrl:]]*}
CC=${CC##* }

# it no work normal, required fix.
CXX=$(type 'g++' 'c++' 2>/dev/null)
CXX=${CXX#*: not found}
CXX=${CXX%%[[:cntrl:]]*}
CXX=${CXX##* }

# it no work normal, required fix.
# ${GCC_VER} ${CHOST}-cpp
CPP=$(type 'cpp' 2>/dev/null)
CPP=${CPP#*: not found}
CPP=${CPP##* }
CPP="${CC} -E"  # testing

# it no work normal, required fix.
LIBTOOL=$(type 'libtool' 2>/dev/null)
LIBTOOL=${LIBTOOL#*: not found}
LIBTOOL=${LIBTOOL##* }

# it must work normal. ok.
MAKE="/bin/make"
MAKE=""  # testing fix: when no install make
test -x "/bin/make"  && export MAKE="make"
test -x "/bin/bmake" && export MAKE="bmake"

QMAKE="/bin/qmake"
test -x "/bin/qmake-qt4" && export QMAKE="/bin/qmake-qt4"
test -x "/bin/qmake-qt5" && export QMAKE="/bin/qmake-qt5"
test -x "/bin/qmake"     && export QMAKE="qmake"

test -n "${CC}"      && export CC=${CC##*/}
test -n "${CXX}"     && export CXX=${CXX##*/}
test -n "${CPP}"     && export CPP=${CPP##*/}
test -n "${LIBTOOL}" && export LIBTOOL=${LIBTOOL##*/}
test -n "${MAKE}"    && export MAKE=${MAKE##*/}
test -n "${QMAKE}"   && export QMAKE=${QMAKE##*/}

test -x "/bin/ar" && export AR="ar"

# test -x /bin/openssl3 && export OPENSSL_PREFIX=/

umask u=rwx,g=rx,o=rx
