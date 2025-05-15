#!/bin/sh
# +static +static-libs -shared -lfs -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit flag-o-matic llvm-r1 meson-multilib python-any-r1 linux-info toolchain-funcs install-functions

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"
LICENSE="MIT SGI-B-2.0"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR="${WORKDIR}/build"
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${WORKDIR}/ || return

# bugfix
CFLAGS=${CFLAGS/-no-pie }
CXXFLAGS=${CXXFLAGS/-no-pie }

meson setup \
  --prefix "${EPREFIX}/" \
  --bindir "bin" \
  --sbindir "sbin" \
  --sysconfdir "etc" \
  --libdir "$(get_libdir)" \
  --includedir "usr/include" \
  --libexecdir "usr/libexec" \
  --datadir "usr/share" \
  --localstatedir "var/lib" \
  --wrap-mode "nodownload" \
  --buildtype "release" \
  -Dplatforms="x11" \
  -Dglx="dri" \
  -Dgallium-drivers="swrast" \
  -Dgallium-nine="false" \
  -Dgallium-va="false" \
  -Dgallium-vdpau="false" \
  -Ddri3="true" \
  -Dopengl="true" \
  -Dllvm="false" \
  -Dosmesa="classic" \
  -Db_ndebug="true" \
  -Dvulkan-drivers="" \
  -Dvalgrind="false" \
  -Dlibunwind="false" \
  -Dbuild-tests="false" \
  "${BUILD_DIR}" \
  || die "meson setup... error"

printf "Configure directory: ${PWD}/... ok\n"

ninja -C "${BUILD_DIR}" || die "Build... Failed"

DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}" || die "meson install... error"

printf %s\\n "Install: ${PN}"

rm -r -- "${WORKDIR}/"*  #${WORKDIR}/meson.build
mkdir -pm 0755 -- "${BUILD_DIR}"
