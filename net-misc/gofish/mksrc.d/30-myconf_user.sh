# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Gofish gopher server"
HOMEPAGE="http://gofish.sourceforge.net"
LICENSE="GPL-2+"
DOCS="Configure_GoFish"

MYCONF="${MYCONF}
 --localstatedir=/var
 --disable-mmap-cache
"
