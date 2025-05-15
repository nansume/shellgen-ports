# -static -static-libs +shared -nls -rpath -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="https://poppler.freedesktop.org/"
LICENSE="GPL-2"
IUSE="-nls -rpath -boost +cairo +cjk +curl +cxx -debug -doc -gpgme -introspection"
IUSE="${IUSE} +jpeg -jpeg2k +lcms -nss +png -qt5 -qt6 -test +tiff +utils"

CMAKEFLAGS="${CMAKEFLAGS}
 -DCMAKE_CXX_STANDARD='14'
 -DBUILD_GTK_TESTS='OFF'
 -DBUILD_QT5_TESTS=$(usex 'test' $(usex 'qt5'))
 -DBUILD_QT6_TESTS=$(usex 'test' $(usex 'qt6'))
 -DBUILD_CPP_TESTS=$(usex 'test')
 -DBUILD_MANUAL_TESTS=$(usex 'test')
 -DTESTDATADIR=${WORKDIR}/test-${TEST_COMMIT}
 -DRUN_GPERF_IF_PRESENT='OFF'
 -DENABLE_BOOST=$(usex 'boost')
 -DENABLE_ZLIB_UNCOMPRESS='OFF'
 -DENABLE_UNSTABLE_API_ABI_HEADERS='ON'
 -DUSE_FLOAT='OFF'
 -DWITH_Cairo=$(usex 'cairo')
 -DENABLE_LIBCURL=$(usex 'curl')
 -DENABLE_CPP=$(usex 'cxx')
 -DENABLE_GPGME=$(usex 'gpgme')
 -DWITH_JPEG=$(usex 'jpeg')
 -DENABLE_DCTDECODER=$(usex 'jpeg' libjpeg none)
 -DENABLE_LIBOPENJPEG=$(usex 'jpeg2k' openjpeg2 none)
 -DENABLE_LCMS=$(usex 'lcms')
 -DENABLE_NSS3=$(usex 'nss')
 -DWITH_PNG=$(usex 'png')
 -DENABLE_QT5=$(usex 'qt5')
 -DENABLE_QT6=$(usex 'qt6')
 -DENABLE_LIBTIFF=$(usex 'tiff')
 -DENABLE_UTILS=$(usex 'utils' ON OFF)
"
