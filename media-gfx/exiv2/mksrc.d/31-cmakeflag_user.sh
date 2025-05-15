# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="EXIF, IPTC and XMP metadata C++ library and command line utility"
HOMEPAGE="https://exiv2.org/"
LICENSE="GPL-2"
IUSE="+bmff -doc -examples -jpegxl -nls +png -test -webready +xmp"

CMAKEFLAGS="${CMAKEFLAGS}
 -DCMAKE_CXX_STANDARD='14'
 -DEXIV2_ENABLE_VIDEO=ON
 -DEXIV2_ENABLE_WEBREADY=$(usex 'webready' ON OFF)
 -DEXIV2_ENABLE_CURL=$(usex 'webready' ON OFF)
 -DEXIV2_ENABLE_INIH=$(usex 'inih' ON OFF)
 -DEXIV2_ENABLE_BROTLI=$(usex 'jpegxl' ON OFF)
 -DEXIV2_ENABLE_XMP=$(usex 'xmp')
 -DEXIV2_ENABLE_BMFF=$(usex 'bmff')
 -DBUILD_WITH_STACK_PROTECTOR=OFF
 -DEXIV2_BUILD_SAMPLES=OFF
 -DEXIV2_ENABLE_NLS=$(usex 'nls')
 -DEXIV2_BUILD_DOC=$(usex 'doc')
 -DEXIV2_BUILD_UNIT_TESTS=$(usex 'test')
 -DPython3_EXECUTABLE=$(usex 'test' python3 true)
"
