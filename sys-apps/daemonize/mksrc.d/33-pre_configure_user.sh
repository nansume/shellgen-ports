#!/bin/sh
# +static +static-libs +shared -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

DESCRIPTION="Runs a command as a Unix daemon"
HOMEPAGE="http://software.clapper.org/daemonize/"
LICENSE="BSD"
DOCS="CHANGELOG.md README.md"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export PN PV EPREFIX DOCS BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed \
  -e 's:\($(CC)\) $(CFLAGS) \(.*\.o\):\1 $(LDFLAGS) \2:' \
  -i Makefile.in || die
