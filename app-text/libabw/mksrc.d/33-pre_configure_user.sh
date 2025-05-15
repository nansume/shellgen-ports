#!/bin/sh
# -static +static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Library parsing abiword documents"
HOMEPAGE="https://wiki.documentfoundation.org/DLP/Libraries/libabw"
LICENSE="MPL-2.0"
IUSE="-doc -tools +static-libs"
BUILD_DIR=${WORKDIR}

MYCONF="${MYCONF}
  --without-docs
  --disable-tools  # BUG: no-build
"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

append-cxxflags -std=c++14
