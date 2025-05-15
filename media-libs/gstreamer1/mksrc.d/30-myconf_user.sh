# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Open source multimedia framework"
HOMEPAGE="https://gstreamer.freedesktop.org/"
LICENSE="LGPL-2+"
IUSE="-caps -introspection -nls -orc -test"

MYCONF="${MYCONF}
 --disable-static
 --disable-nls
 --disable-valgrind
 --disable-examples
 --disable-debug
 --enable-check
 --disable-introspection
 --disable-tests
 --with-ptp-helper-permissions=setuid-root
 --with-ptp-helper-setuid-user=nobody
 --with-ptp-helper-setuid-group=nobody
"
