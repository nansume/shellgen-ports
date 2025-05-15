# -static -static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="OpenGL Mathematics"
HOMEPAGE="http://glm.g-truc.net/"
LICENSE="|| ( HappyBunny MIT )"
IUSE="-test +cpu_flags_x86_sse2 -cpu_flags_x86_sse3 -cpu_flags_x86_ssse3 -cpu_flags_x86_sse4_1"
IUSE="${IUSE} -cpu_flags_x86_sse4_2 -cpu_flags_x86_avx -cpu_flags_x86_avx2"

EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
FILESDIR=${FILESDIR:-$DISTSOURCE}
ED=${ED:-$INSTALL_DIR}

CMAKEFLAGS="${CMAKEFLAGS}
 -DGLM_BUILD_INSTALL=ON
 -DGLM_BUILD_LIBRARY=OFF
 -DGLM_BUILD_TESTS=OFF
"

sed \
 -e "s:@CMAKE_INSTALL_PREFIX@:${EPREFIX%/}/usr:" \
 -e "s:@GLM_VERSION@:1.0:" \
 "${FILESDIR}"/glm.pc.in \
 > "${BUILD_DIR}/glm.pc" || die

mkdir -pm 0755 -- "${ED}"/usr/share/pkgconfig/
mv -n "${BUILD_DIR}/glm.pc" -t "${ED}"/usr/share/pkgconfig/ &&
printf %s\\n "Install: glm.pc"
