#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Generic-purpose lossless compression algorithm"
HOMEPAGE="https://github.com/google/brotli/"
LICENSE="MIT python? ( Apache-2.0 )"
IUSE="-python -test"
WORKDIR=${WORKDIR%/*}
