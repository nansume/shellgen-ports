# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Adwaita GTK+2 theme engine"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gnome-themes-extra/"
LICENSE="LGPL-2.1+"

MYCONF="${MYCONF}
 --disable-static
 --enable-gtk2-engine
 --disable-gtk3-engine
 GTK_UPDATE_ICON_CACHE=$(type -P true)
"
