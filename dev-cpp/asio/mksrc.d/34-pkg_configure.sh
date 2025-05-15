#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit autotools install-functions

DESCRIPTION="Asynchronous Network Library"
HOMEPAGE="https://think-async.com https://github.com/chriskohlhoff/asio"
LICENSE="Boost-1.0"
IUSE="-examples -test"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-src/${PN}"
BUILD_DIR=${WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

patch -p1 -E < "${FILESDIR}/asio-1.30.1-pkgconfig.patch"

autoreconf --install

if ! use 'test'; then
# Don't build nor install any examples or unittests
# since we don't have a script to run them
cat > src/Makefile.in <<-EOF || die
all:

install:

clean:
EOF
fi

./configure ${MYCONF} || return

printf "Configure directory: ${PWD}/... ok\n"
