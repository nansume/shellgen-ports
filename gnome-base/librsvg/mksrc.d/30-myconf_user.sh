# -static +static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"
LICENSE="LGPL-2+"
IUSE="+introspection -tools -vala"

MYCONF="${MYCONF}
 $(use_enable 'static-libs' static)
 --disable-tools
 $(use_enable 'introspection')
 --disable-vala
 --enable-pixbuf-loader
"
