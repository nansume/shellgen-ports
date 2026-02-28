# Build with useflag: +static +static-libs -shared -lfs +nopie -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="Tiny, fully-functional, platform-independant webserver"
HOMEPAGE="https://github.com/zorxx/microhttpd/"
LICENSE="MIT"
IUSE="+examples +static +static-libs -shared -doc (+musl) +stest +strip"

CMAKEFLAGS="${CMAKEFLAGS}
 -DMICROHTTPD_BUILD_EXAMPLES=$(usex 'examples' OFF ON)
"
