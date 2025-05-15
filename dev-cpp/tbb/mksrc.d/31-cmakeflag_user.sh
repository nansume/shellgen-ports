# -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="High level abstract threading library"
HOMEPAGE="https://github.com/oneapi-src/oneTBB"
LICENSE="Apache-2.0"
IUSE=" -test"

CMAKEFLAGS="${CMAKEFLAGS}
 -DTBB_TEST=OFF
 -DTBB_ENABLE_IPO=OFF
 -DTBB_STRICT=OFF
"