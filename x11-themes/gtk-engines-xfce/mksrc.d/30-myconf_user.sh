# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A port of Xfce engine to GTK+ 2.x"
HOMEPAGE="https://git.xfce.org/xfce/gtk-xfce-engine/"
LICENSE="GPL-2"

MYCONF="${MYCONF}
 --enable-gtk2-engine
 --disable-gtk3-engine
"
