#!/bin/sh
# -static -static-libs +shared -nopie -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A Python crypto and SSL toolkit"
HOMEPAGE="https://gitlab.com/m2crypto/m2crypto/"
LICENSE="MIT openssl"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# add support: x32-abi
case ${ABI} in
  'x32') export SWIG_FEATURES="-D__ILP32__" ;;
esac
