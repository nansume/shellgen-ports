#!/bin/sh
# Usage: USE=-ssl uriparser_standalone
# static-libs build for bundle

uriparser_standalone() {

uriparser_static_pkgsetup() {
  SRC_URI="${SRC_URI#${SRC_URI%%[![:space:]]*}}"

  pkginst \
    "dev-build/cmake3" \
    "dev-util/pkgconf" \
    || die "Failed install build pkg depend... error"

  [ x"${USER}" = x'root' ] && printf %s\\n "${SRC_URI}" >> "${SRCLIST}"
  netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
}

uriparser_static_compile() {
  cd "${FILESDIR}/"
  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  rm -- "${PF}"
  sed -e "s|${SRC_URI}||" -i "${PDIR%/}/${SRCLIST}"

  prepare
  prepare() { :;}

  cd "${WORKDIR}/${PN}-${PV}/"

  cmake -B . -G "Unix Makefiles" \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}" \
    -DCMAKE_INSTALL_LIBDIR="$(get_libdir)" \
    -DCMAKE_INSTALL_INCLUDEDIR="${INCDIR#/}" \
    -DCMAKE_BUILD_TYPE="None" \
    -DURIPARSER_BUILD_CHAR=ON \
    -DURIPARSER_BUILD_DOCS=OFF \
    -DURIPARSER_BUILD_TESTS=OFF \
    -DURIPARSER_BUILD_TOOLS=OFF \
    -DURIPARSER_BUILD_WCHAR_T=$(usex 'unicode' ON OFF) \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_SKIP_RPATH=ON \
    -Wno-dev \
    || die "Failed cmake build"

  DESTDIR="${BUILD_DIR}/${PN}" cmake --build . --target install -j "$(nproc)" || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN}/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN}/$(get_libdir)"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN}/${LIB_DIR}/pkgconfig"
}

  local IFS="$(printf '\n\t')"
  local SRCLIST=${SRCLIST:-src_uri.lst}
  local PN="uriparser"
  local PV="0.9.8"
  local IUSE="+unicode"
  local SRC_URI="https://github.com/${PN}/${PN}/releases/download/${PN}-${PV}/${PN}-${PV}.tar.bz2"
  local PF=$(pfname 'src_uri.lst' "${SRC_URI}")
  local ZCOMP="bunzip2"

  uriparser_static_pkgsetup
  [ x"${USER}" != x'root' ] && uriparser_static_compile

  if [ -d "${BUILD_DIR}" ]; then
    cd "${BUILD_DIR}/"
  elif [ -d "${WORKDIR}" ]; then
    cd "${WORKDIR}/"
  fi
}
