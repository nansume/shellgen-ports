DESCRIPTION="DjVu viewers, encoders and utilities"
HOMEPAGE="https://djvu.sourceforge.net/"
LICENSE="GPL-2+"
IUSE="-debug -doc +jpeg +tiff +xml"

MYCONF="${MYCONF}
 --disable-desktopfiles
"

# You must still update various caches with:
#update-mime-database /usr/share/mime
#update-icon-caches /usr/share/icons/hicolor
