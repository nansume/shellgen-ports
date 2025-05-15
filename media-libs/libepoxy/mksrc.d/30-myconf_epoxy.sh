# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Epoxy is a library for handling OpenGL function pointer management for you"
HOMEPAGE="https://github.com/anholt/libepoxy"
LICENSE="MIT"
IUSE="-test +X"

MYCONF="${MYCONF}
 --enable-x11=yes
 --enable-glx=yes
 --enable-egl=yes
"
