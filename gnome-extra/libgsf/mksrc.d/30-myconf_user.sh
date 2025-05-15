# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The GNOME Structured File Library"
HOMEPAGE="https://developer.gnome.org/gsf/"
LICENSE="GPL-2 LGPL-2.1"
IUSE="-bzip2 +gtk -introspection"

MYCONF="${MYCONF}
 --disable-static
 $(use_with 'bzip2' bz2)
 $(use_enable 'introspection')
 $(use_with 'gtk' gdk-pixbuf)
"
