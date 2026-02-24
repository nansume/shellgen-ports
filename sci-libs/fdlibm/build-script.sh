#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-18 15:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/science/sci-libs/fdlibm/fdlibm-5.3.1.ebuild

EAPI=8

inherit cmake

DESCRIPTION="C math library supporting IEEE 754 floating-point arithmetic"
HOMEPAGE="https://www.netlib.org/fdlibm"
LICENSE="freedist"
PN="fdlibm"
PV="5.3.1"
SRC_URI="
  https://github.com/batlogic/fdlibm/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/science/sci-libs/${PN}/files/${PN}-no-Werror.patch
"
IUSE="+static-libs +shared -doc (+musl) +strip"

pkgins() { pkginst \
  "dev-build/cmake3" \
  "dev-util/pkgconf" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

build() {
  mv CMakelists.txt CMakeLists.txt || die

  patch -p1 -E < "${FILESDIR}/${PN}-no-Werror.patch"
  patch -p1 -E < "${PDIR%/}/patches/${PN}-add-staticlib-v01.diff"

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="/usr" \
    -D CMAKE_BUILD_TYPE="None" \
    -D BUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"

  mkdir -m 0755 -- ${ED}/usr/share/ ${ED}/usr/share/${PN}/
  mv "${ED}/usr/lib" "${ED}/$(get_libdir)" || die
  mv "${ED}/usr/src" -t "${ED}/usr/share/${PN}/" || die
}
