# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
LICENSE="MIT"
IUSE="-debug -static-libs"
EPREFIX=${SPREFIX}
BUILD_DIR="${WORKDIR}/build"

test "X${USER}" != 'Xroot' || return 0

mkdir -m 0755 "${BUILD_DIR}/"

cd ${BUILD_DIR}/ || return

cmake \
  -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
  -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
  -DCMAKE_INSTALL_SBINDIR="sbin" \
  -DCMAKE_INSTALL_SYSCONFDIR="etc" \
  -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
  -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR}" \
  -DCMAKE_INSTALL_LIBEXECDIR="${DPREFIX}/libexec" \
  -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
  -DCMAKE_INSTALL_DOCDIR="${DPREFIX}/share/doc" \
  -DCMAKE_INSTALL_INFODIR="${DPREFIX}/share/info" \
  -DCMAKE_INSTALL_LOCALEDIR="${DPREFIX}/share/locale" \
  -DCMAKE_INSTALL_MANDIR="${DPREFIX}/share/man" \
  -DCMAKE_BUILD_TYPE="Release" \
  -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
  -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
  -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
  -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
  -DFREEGLUT_GLES='OFF' \
  -DFREEGLUT_BUILD_STATIC_LIBS=$(usex 'static-libs' ON OFF) \
  -Wno-dev \
  .. || die "Failed cmake build"
