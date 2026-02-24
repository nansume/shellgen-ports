#!/bin/sh

cmake_src_configure(){
  IFS="$(printf '\n\t')"

  #append-flags -DNDEBUG

  use 'strip' && TARGET_INST="install/strip"

  cmake -B . -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_BINDIR="bin" \
    -DCMAKE_INSTALL_SBINDIR="sbin" \
    -DCMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX#/}/share" \
    -DCMAKE_INSTALL_DOCDIR="${DPREFIX#/}/share/doc" \
    -DCMAKE_BUILD_TYPE="None" \
    ${mycmakeargs} \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${ED}" cmake --build . --target ${TARGET_INST} -j "$(nproc)" || die "make install... error"
}
