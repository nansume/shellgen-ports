#!/bin/sh
# +static -static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A Library for Large Linear Classification"
HOMEPAGE="https://www.csie.ntu.edu.tw/~cjlin/liblinear/ https://github.com/cjlin1/liblinear"
LICENSE="BSD"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS="predict train"

local IFS="${NL} "

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

sed -i -e '/^CFLAGS/d;/^CXXFLAGS/d' blas/Makefile || die

sed -i \
  -e 's|make|$(MAKE)|g' \
  -e '/$(LIBS)/s|$(CFLAGS)|& $(LDFLAGS)|g' \
  -e '/^CFLAGS/d;/^CXXFLAGS/d' \
  -e 's|$(SHARED_LIB_FLAG)|& $(LDFLAGS)|g' \
  Makefile || die

append-cflags -fPIC

make -j"$(nproc)" V='0' \
  CC="${CC}" \
  CXX="${CXX}" \
  prefix='' \
  libdir="/$(get_libdir)" \
  includedir="/usr/include" \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  lib all \
  || die "Failed make build"

mkdir -pm 0755 "${ED}"/bin/ "${ED}"/$(get_libdir)/ "${ED}"/usr/include/
mv -n ${PROGS} "${ED}"/bin/ &&
mv -n ${PN}.so.5 "${ED}"/$(get_libdir)/ &&
ln -s ${PN}.so.5 "${ED}"/$(get_libdir)/${PN}.so &&
mv -n linear.h "${ED}"/usr/include/ &&
printf %s\\n "Install: ${PROGS} bin/"
