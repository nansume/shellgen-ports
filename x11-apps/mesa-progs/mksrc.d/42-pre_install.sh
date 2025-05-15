#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Mesa's OpenGL utility and demo programs (glxgears and glxinfo)"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/ https://gitlab.freedesktop.org/mesa/demos"
LICENSE="LGPL-2"
IUSE="+egl +gles2"
ED=${ED:-$INSTALL_DIR}
PROGS="src/xdemos/glxgears src/xdemos/glxinfo src/egl/opengl/eglinfo src/egl/opengl/eglgears_x11"
PROGS="${PROGS} src/egl/opengles2/es2_info src/egl/opengles2/es2gears_x11"

test "X${USER}" != 'Xroot' || return 0

cd "${WORKDIR}/" || return

mkdir -pm 0755 -- "${ED}"/bin/
mv -n ${PROGS} -t "${ED}"/bin/ &&
printf %s\\n "Install: ${PN}"
