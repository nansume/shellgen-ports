# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"
LICENSE="LGPL-2+"
IUSE="-introspection -tools -vala"

MYCONF="${MYCONF}
 --disable-static
 --disable-tools
 --disable-introspection
 --disable-vala
 --enable-pixbuf-loader
"
