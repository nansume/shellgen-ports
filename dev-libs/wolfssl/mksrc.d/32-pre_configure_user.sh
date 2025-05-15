#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Embedded SSL library."
HOMEPAGE="https://www.wolfssl.com/ https://github.com/wolfSSL/wolfssl"
LICENSE="GPL-2"
IUSE="-debug +cpu_flags_x86_aes -sniffer +writedup"
BUILD_DIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

chmod +x "configure" "build-aux/"*

# fix busybox cut opt no support: --version
sed -i "s/cut --version/:/" configure
