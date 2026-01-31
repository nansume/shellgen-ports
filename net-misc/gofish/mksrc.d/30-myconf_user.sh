# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# http://gpo.zugaina.org/net-misc/gofish

DESCRIPTION="Gofish gopher server (standalone-server, gateway via http)"
HOMEPAGE="http://gofish.sourceforge.net"
LICENSE="GPL-2+"
DOCS="Configure_GoFish"

MYCONF="${MYCONF}
 --localstatedir=/var
 --disable-mmap-cache
"
