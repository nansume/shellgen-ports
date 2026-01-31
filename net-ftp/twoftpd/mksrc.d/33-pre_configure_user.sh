#!/bin/sh
# +static -static-libs -shared -upx +patch -doc -man -xstub +diet -musl -stest +strip +x32

# http://gpo.zugaina.org/net-ftp/twoftpd

inherit toolchain-funcs

DESCRIPTION="Simple secure efficient FTP server by Bruce Guenter (inetd, diet)"
HOMEPAGE="http://untroubled.org/twoftpd/"
LICENSE="GPL-2"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
EPREFIX=${EPREFIX:-$SPREFIX}

export EPREFIX BUILD_DIR

local EPREFIX=${SPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

printf '%s\n' "/sbin" > conf-bin || die
printf '%s\n' "/usr/share/man" > conf-man || die
printf '%s\n' "${CC} ${CFLAGS} -I/usr/include/bglibs" > conf-cc || die
printf '%s\n' "${CC} -s -L/$(get_libdir)/bglibs" > conf-ld || die
