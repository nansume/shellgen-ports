# -static +static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A vector graphics library with cross-device output support"
HOMEPAGE="https://www.cairographics.org"
LICENSE="|| ( LGPL-2.1 MPL-1.1 )"
IUSE="-X -aqua -debug -gles2 +glib -opengl +directfb -static-libs +svg -valgrind -xcb"

export ax_cv_c_float_words_bigendian="no"

MYCONF="${MYCONF}
 --disable-dependency-tracking
 $(use_with 'X' x)
 $(use_enable 'X' tee)
 $(use_enable 'X' xlib)
 $(use_enable 'X' xlib-xrender)
 $(use_enable 'aqua' quartz)
 $(use_enable 'aqua' quartz-image)
 $(use_enable 'debug' test-surfaces)
 $(use_enable 'gles2' glesv2)
 $(use_enable 'glib' gobject)
 $(use_enable 'opengl' gl)
 $(use_enable 'svg')
 $(use_enable 'valgrind')
 $(use_enable 'xcb')
 $(use_enable 'xcb' xcb-shm)
 --enable-ft
 --enable-pdf
 --enable-png
 --enable-ps
 --disable-drm
 --enable-directfb
 --disable-gallium
 --disable-qt
 --disable-vg
 --disable-xlib-xcb
"

test "X${USER}" != 'Xroot' || return 0

test -x "/bin/perl" && autoreconf --install
