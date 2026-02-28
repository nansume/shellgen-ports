#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-26 15:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/nanomsg/nanomsg-1.2.2.ebuild

# BUG: build only static libs or shared libs

EAPI=8

inherit cmake

DESCRIPTION="High-performance messaging interface for distributed applications"
HOMEPAGE="https://nanomsg.org/"
LICENSE="MIT"
PN="nanomsg"
PV="1.2.2"
SRC_URI="https://github.com/nanomsg/nanomsg/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="-doc -test +static +static-libs -shared (+musl) +stest +strip"
PROG="bin/nanocat"

pkgins() { pkginst \
  "dev-build/cmake3" \
  "dev-util/pkgconf" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # Old CPUs like HPPA fail tests because of timeout
  sed -i \
    -e '/inproc_shutdown/s/10/80/' \
    -e '/ws_async_shutdown/s/10/80/' \
    -e '/ipc_shutdown/s/40/80/' CMakeLists.txt || die

  rm -vr demo || die  # unused, causing bug #963845
}

src_configure() {
  use 'strip' && TARGET_INST="install/strip"

  cmake -B build -G "Unix Makefiles" \
    -D CMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -D CMAKE_INSTALL_BINDIR="bin" \
    -D CMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -D CMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -D CMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -D CMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -D CMAKE_BUILD_TYPE="None" \
    -D NN_ENABLE_NANOCAT="ON" \
    -D NN_STATIC_LIB=$(usex 'static-libs' ON OFF) \
    -D NN_ENABLE_DOC=$(usex 'doc') \
    -D NN_TESTS=$(usex 'test') \
    -D CMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -W no-dev \
    || die "Failed cmake build"
}

src_compile() {
  DESTDIR="${ED}" cmake --build build --target ${inst} -j "$(nproc)" || die "make install... error"
}

src_install() { :;}
