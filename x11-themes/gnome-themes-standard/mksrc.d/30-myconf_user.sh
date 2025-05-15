# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Standard Themes for GNOME Applications"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-themes-extra"
LICENSE="LGPL-2.1+"

MYCONF="${MYCONF}
 --disable-static
 --disable-gtk2-engine
 --disable-gtk3-engine
 GTK_UPDATE_ICON_CACHE=$(type -P true)
"

test "X${USER}" != 'Xroot' || return 0

autoreconf --install
