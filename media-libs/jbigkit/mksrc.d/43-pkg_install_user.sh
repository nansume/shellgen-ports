#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="data compression algorithm for bi-level high-resolution images"
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
LICENSE="GPL-2"
IUSE="+static-libs"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

export ED

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

dobin 'pbmtools/jbgtopbm' 'pbmtools/jbgtopbm85' 'pbmtools/pbmtojbg' 'pbmtools/pbmtojbg85'
doman 'pbmtools/jbgtopbm.1' 'pbmtools/pbmtojbg.1'
doheader 'libjbig/'*.h
dolib.so 'libjbig/libjbig.so' 'libjbig/libjbig85.so'
use 'static-libs' && dolib.a 'libjbig/libjbig.a' 'libjbig/libjbig85.a'

printf %s\\n "Install: ${PN}... ok"
