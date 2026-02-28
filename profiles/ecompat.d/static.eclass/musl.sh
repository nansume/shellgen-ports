#!/bin/sh
# Usage: USE=-shared uriparser_standalone
# static-libs build for bundle

musl_standalone() {

musl_static_pkgsetup() {
  [ x"${USER}" = x'root' ] || return 0
  SRC_URI="${SRC_URI#${SRC_URI%%[![:space:]]*}}"

  printf %s\\n "${SRC_URI}" > "${SRCLIST}"
  netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
  > "${PDIR%/}/${SRCLIST}"
}

musl_static_compile() {
  [ x"${USER}" != x'root' ] || return 0

  cd "${FILESDIR}/"
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit
  rm -- "${PF}"
  #sed -e "s|${SRC_URI}||" -i "${PDIR%/}/${SRCLIST}"
  #> "${PDIR%/}/${SRCLIST}"

  cd "${WORKDIR}/${PN}-${PV}/"

  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-iconv-euc-kr.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-fix-iconv-input-utf8.patch
  patch -p1 -E < "${FILESDIR}"/musl-sched.h-reduce-namespace-conflicts.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-read_timezone_from_fs.patch
  patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-nftw-support-common-gnu-ext.patch
  patch -p1 -E < "${FILESDIR}"/musl-1.2.5-add-recallocarray-v4.diff  # it exists in libbsd

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --syslibdir="${EPREFIX%/}/$(get_libdir)" \
    --enable-wrapper=no \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${BUILD_DIR}/${PN}" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN}/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN}/$(get_libdir) -lc"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN}/${LIB_DIR}/pkgconfig"
}

  local IFS="$(printf '\n\t')"
  local SRCLIST=${SRCLIST:-src_uri.lst}
  local PN="musl"
  local PV="1.2.5"
  local SRC_URI="
    http://musl.libc.org/releases/${PN}-${PV}.tar.gz
    https://www.openwall.com/lists/musl/2025/02/13/1/1 -> ${PN}-${PV}-fix-iconv-euc-kr.patch
    https://www.openwall.com/lists/musl/2025/02/13/1/2 -> ${PN}-${PV}-fix-iconv-input-utf8.patch
    http://data.gpo.zugaina.org/gentoo/sys-libs/musl/files/musl-sched.h-reduce-namespace-conflicts.patch
    http://localhost/pub/distfiles/patch/musl-1.2.5-read_timezone_from_fs.patch
    http://localhost/pub/distfiles/patch/musl-1.2.5-nftw-support-common-gnu-ext.patch
    http://localhost/pub/distfiles/patch/musl-1.2.5-add-recallocarray-v4.diff
  "
  local PF=$(pfname 'src_uri.lst' "${SRC_URI}")
  local ZCOMP="gunzip"

  musl_static_pkgsetup
  musl_static_compile

  if [ -d "${BUILD_DIR}" ]; then
    cd "${BUILD_DIR}/"
  elif [ -d "${WORKDIR}" ]; then
    cd "${WORKDIR}/"
  fi
}
