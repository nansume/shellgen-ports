# -static -static-libs +shared +patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="High-performance, full-featured text search engine based off of lucene in C++"
HOMEPAGE="https://clucene.sourceforge.net"
LICENSE="|| ( Apache-2.0 LGPL-2.1 )"
IUSE="-debug -doc -static-libs -static +shared (+musl) -xstub +stest +strip"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

CMAKEFLAGS="${CMAKEFLAGS}
 -DENABLE_ASCII_MODE='OFF'
 -DENABLE_PACKAGING='OFF'
 -DDISABLE_MULTITHREADING='OFF'  # see upstream bug: https://sourceforge.net/p/clucene/bugs/197/
 -DBUILD_CONTRIBS_LIB='ON'
 -DLIB_DESTINATION=/$(get_libdir)
 -DENABLE_DEBUG='OFF'
 -DENABLE_CLDOCS=$(usex 'doc')
 -DBUILD_STATIC_LIBRARIES=$(usex 'static-libs')
"

# patch out installing bundled boost headers, we build against system one
sed -e '/ADD_SUBDIRECTORY (src\/ext)/d' -i CMakeLists.txt || die
rm -r -- "src/ext/" || die