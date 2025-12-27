#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools flag-o-matic tmpfiles install-functions

DESCRIPTION="Clam Anti-Virus Scanner"
HOMEPAGE="https://www.clamav.net/"
LICENSE="GPL-2"  # --disable-unrar otherwise a nofree unRAR license
IUSE="-bzip2 -doc -clamonacc -clamdtop -clamsubmit +iconv +ipv6 -libclamav-only"
IUSE="${IUSE} -milter -metadata-analysis-api -selinux -systemd -test -xml"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX%/}; local S=${BUILD_DIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

#AT_NO_RECURSIVE="yes" autoreconf --install

use 'musl' && append-ldflags -lfts

JSONUSE="--without-libjson"

if use 'clamsubmit' || use 'metadata-analysis-api'; then
  JSONUSE="--with-libjson=${EPREFIX}/usr"
fi

rm -r libclamav/tomsfastmath || die "failed to remove bundled tomsfastmath"

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'bzip2') \
  --disable-unrar \
  $(use_enable 'clamonacc') \
  $(use_enable 'clamdtop') \
  $(use_enable 'ipv6') \
  $(use_enable 'milter') \
  $(use_enable 'test' check) \
  $(use_with 'xml') \
  $(use_with 'iconv') \
  ${JSONUSE} \
  $(use_enable 'libclamav-only') \
  $(use_with !libclamav-only libcurl) \
  --with-system-libmspack \
  --cache-file="${S}"/config.cache \
  --disable-experimental \
  --disable-static \
  --disable-zlib-vcheck \
  --enable-id-check \
  --with-dbdir="${EPREFIX}"/var/lib/clamav \
  --with-zlib \
  --disable-llvm \
  --disable-openrc \
  --runstatedir=/run \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
