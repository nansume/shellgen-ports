#!/bin/sh
# +static +static-libs +shared -patch -doc -xstub -diet +musl -stest +strip +x32

DESCRIPTION="Password hashing software that won the Password Hashing Competition (PHC)"
HOMEPAGE="https://github.com/P-H-C/phc-winner-argon2"
LICENSE="|| ( Apache-2.0 CC0-1.0 )"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
OPTTEST="0"

local IFS="${NL} "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

if ! use 'static-libs'; then
  sed -i -e '/LIBRARIES =/s/\$(LIB_ST)//' Makefile || die
fi
sed -i \
  -e 's/-O3//' \
  -e 's/-g//' \
  -e 's/-march=\$(OPTTARGET)//' \
  Makefile || die

make -j"$(nproc)" V='0' \
  OPTTEST="${OPTTEST}" \
  CC="${CC}" \
  CXX="${CXX}" \
  DESTDIR=${ED} \
  PREFIX='' \
  LIBRARY_REL="$(get_libdir)" \
  includedir="/usr/include" \
  ARGON2_VERSION="0~${PV}" \
  all install \
  || die "Failed make build"

rm -- Makefile
