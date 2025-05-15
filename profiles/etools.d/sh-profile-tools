#!/bin/sh
# Copyright (C) 2020-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 18:00 UTC - fix: near to compat-posix

#[[ ${TTY-} ]] && { (( TTY != 5 )) && [[ ${BASH_SOURCE[@]} != *mksrc.sh* ]] && return;}
#case ${USER} in
#  tools|root) #shopt -so nounset  # this block build pkg - test
#  ;;
#  *) return ;;
#esac
test "X${USER}" != 'Xroot' || return 0

# this block build pkg - test
#trap '
#  printf \e[4m${_}\e[m...\e[31m error\e[m\n
#  exec bash --login
#' ERR

# interactive login shell
if test -n "${PS1-}" && test -n "${ps1-}"; then
  # build tools (sources)
  PS1='\[\e[m\](\[\e[0;34m\]compile\[\e[m\]) '
  PS1=${PS1}${ps1}
  test -n "${DISPLAY-}" && TERM='rxvt-unicode'
else
# non-interactive shell
#shopt -so errexit  # this block build pkg - test
:
fi
export ABI_BUILD=${ABI_BUILD:=x32}
export ABI=${ABI:=x32}
test "${BUILD_CHROOT:=0}" -ne '0' && ABI=${ABI_BUILD:=x32}
export XABI=${XABI:=x32}
printf %s\\n "ABI='${ABI}'" "XABI='${XABI}'" "ABI_BUILD='${ABI_BUILD}'" "\$0='${0}'"

HOSTTYPE=$(uname -m)
OSTYPE=$(uname -s)

case ${ABI} in
  'x86')
    HOSTTYPE='i686'
    OSTYPE='linux-musl'
    CHOST="${HOSTTYPE}-${OSTYPE}"
    CFLAGS="${CFLAGS:+${CFLAGS} }-m32"
    # -mfpmath=sse,387
    CFLAGS=$(printf %s " ${CFLAGS} " | sed 's/ -msse2 / -msse -mfpmath=sse /;s/^ *//;s/ *$//')
    MACHTYPE=${CHOST}
    #ABI_X86=32
    #KERNEL_ABI=${ABI}
    #CPU_FLAGS_X86=sse
    #################################
    LIB_DIR='lib32'
    LIBDIR='/lib32'
  ;;
  'x32')
    # ? ARCH=x32
    printf %s\\n "test: OSTYPE='${OSTYPE}'"
    test "x${OSTYPE}" = 'xLinux' && OSTYPE="linux-muslx32"
    printf %s\\n "test: MACHTYPE='${MACHTYPE}'"
    MACHTYPE=${HOSTTYPE}
    if { check-pkg 'sys-libs/glibc' ${ABI} || check-pkg 'sys-libs/glibc-compat' ${ABI} ;} >/dev/null; then
      OSTYPE="linux-gnux32"
    elif { check-pkg 'sys-glibc/glibc' ${ABI} || check-pkg 'sys-glibc/glibc-compat' ${ABI} ;} >/dev/null; then
      OSTYPE="linux-gnux32"
    elif use 'glibc'; then
      OSTYPE="linux-gnux32"
    elif check-pkg "sys-libs/musl" ${ABI} >/dev/null; then
      OSTYPE="linux-muslx32"
    elif use 'musl'; then
      OSTYPE="linux-muslx32"
    fi
    #OSTYPE="linux-muslx32"
    printf %s\\n "test: HOSTTYPE='${HOSTTYPE}'" "test: MACHTYPE='${MACHTYPE}'" "test: OSTYPE='${OSTYPE}'"

    if test "x${OSTYPE}" = 'xlinux-gnux32'; then
      CHOST="${HOSTTYPE}-pc-${OSTYPE}"
    else
      CHOST="${HOSTTYPE}-${OSTYPE}"
    fi
    CFLAGS="${CFLAGS:+${CFLAGS} }-m${ABI}"
    #################################
    LIB_DIR='libx32'
    LIBDIR='/libx32'
  ;;
  'amd64')
    HOSTTYPE='x86_64'
    OSTYPE='linux-musl'
    CHOST="${HOSTTYPE}-${OSTYPE}"
    MACHTYPE=${CHOST}
    CFLAGS="${CFLAGS:+${CFLAGS} }-m64"
    #################################
    LIB_DIR='lib64'
    LIBDIR='/lib64'
    XABI='64'
  ;;
esac
CFLAGS="${CFLAGS:+${CFLAGS} }-march=${HOSTTYPE%_*}-${HOSTTYPE#*_}"
CPPFLAGS="${CPPFLAGS:+${CPPFLAGS} }-march=${HOSTTYPE%_*}-${HOSTTYPE#*_}"
CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }-march=${HOSTTYPE%_*}-${HOSTTYPE#*_}"
FCFLAGS="${FCFLAGS:+${FCFLAGS} }-march=${HOSTTYPE%_*}-${HOSTTYPE#*_}"
FFLAGS="${FFLAGS:+${FFLAGS} }-march=${HOSTTYPE%_*}-${HOSTTYPE#*_}"
unset LANG ps1

export LIB_DIR=${LIB_DIR:=libx32}
export LIBDIR=${LIBDIR:=/libx32}

: ${HOSTTYPE:?} ${OSTYPE:?} ${CHOST:?} ${MACHTYPE:?}

export HOSTTYPE OSTYPE CHOST MACHTYPE
