# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32 - ok
# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32 - ok

inherit cmake python-single-r1 xdg

DESCRIPTION="Android File Transfer for Linux"
HOMEPAGE="https://github.com/whoozle/android-file-transfer-linux"
LICENSE="LGPL-2.1"
IUSE="+fuse -python -qt5 -shared -usb -taglib -zune"

CMAKEFLAGS="${CMAKEFLAGS}
 -DBUILD_FUSE=$(usex 'fuse')
 -DBUILD_MTPZ=$(usex 'zune')
 -DBUILD_PYTHON=$(usex 'python')
 -DBUILD_QT_UI=$(usex 'qt5')
 -DBUILD_SHARED_LIB=$(usex 'shared')
 -DBUILD_TAGLIB=$(usex 'taglib')
 -DUSB_BACKEND_LIBUSB=$(usex 'usb')
"
