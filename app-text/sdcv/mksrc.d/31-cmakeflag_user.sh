# +static -static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Console version of Stardict program"
HOMEPAGE="https://dushistov.github.io/sdcv/"
LICENSE="GPL-2"
IUSE="+static -nls -rpath -darkterm -nls -readline -doc (+musl) -xstub +stest -test +strip"

CMAKEFLAGS="${CMAKEFLAGS}
 -DWITH_READLINE=$(usex 'readline')
 -DBUILD_TESTS=$(usex 'test' ON OFF)
"
