# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="C++ JSON reader and writer"
HOMEPAGE="https://github.com/open-source-parsers/jsoncpp/"
LICENSE="|| ( public-domain MIT )"
IUSE="-doc -test"
EPREFIX=${SPREFIX}
BUILD_DIR="${WORKDIR}/build"
WORKDIR=${BUILD_DIR}
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}${LD_LIBRARY_PATH:+:}${BUILD_DIR}/lib"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

mkdir -m 0755 "${BUILD_DIR}/"

cd ${BUILD_DIR}/ || return

cmake \
  -DCMAKE_INSTALL_PREFIX="${EPREFIX}" \
  -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
  -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_CXX_STANDARD="14" \
  -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
  -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
  -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
  -DBUILD_STATIC_LIBS=$(usex 'static-libs' ON OFF) \
  -Wno-dev \
  .. || die "Failed cmake build"
