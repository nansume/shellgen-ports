#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="An efficient, principled regular expression library"
HOMEPAGE="https://github.com/google/re2"
LICENSE="BSD"
SONAME="11"
IUSE="-icu"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS="${PN} bin/antiword kantiword"

local IFS="${NL} "
local MAKEFLAGS=; unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

grep -q "^SONAME=${SONAME}\$" Makefile || die "SONAME mismatch"

if use 'icu'; then
  sed -i -e 's:^# \(\(CC\|LD\)ICU=.*\):\1:' Makefile || die
fi

#sed -i -e '/^CFLAGS/d;/^CXXFLAGS/d' blas/Makefile || die
: sed -i \
  -e 's|make|$(MAKE)|g' \
  -e '/$(LIBS)/s|$(CFLAGS)|& $(LDFLAGS)|g' \
  -e '/^CFLAGS/d;/^CXXFLAGS/d' \
  -e 's|$(SHARED_LIB_FLAG)|& $(LDFLAGS)|g' \
  Makefile || die
: sed -i \
  -e "/^CFLAGS = /s/ -O2 / ${CFLAGS} /" \
  -e "/^LDFLAGS = /s/ -O2 / ${LDFLAGS} /" \
  -e "s/^PLUGINS = .*/PLUGINS = /" \
  Makefile || die

#append-cflags -fPIC

${MAKE} -j"$(nproc --ignore=1)" V='0' \
  ${MAKEFLAGS} \
  CC="${CC}" \
  CXX="${CXX}" \
  DESTDIR=${ED} \
  prefix='' \
  libdir="/$(get_libdir)" \
  includedir="/usr/include" \
  SONAME="${SONAME}" \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  shared shared-install \
  || die "Failed make build"

: sed -i "s:^BINDIR = .*:BINDIR = ${ED}/bin:" Makefile || die

: ${MAKE} V='0' \
  DESTDIR=${ED} \
  prefix='' \
  PREFIX='' \
  LIBDIR="/$(get_libdir)" \
  includedir="/usr/include" \
  install-header install-shared install \
  || die "make install... error"

rm -- Makefile

#mkdir -pm 0755 "${ED}"/ "${ED}"/bin/ "${ED}"/$(get_libdir)/ "${ED}"/usr/include/
#mv -n ${PROGS} bin/${PN} bin/ftppr bin/mycrypt bin/pop3p "${ED}"/bin/ &&
#mv -n lib${PN}*.[sa]* lib${PN}*.so.* "${ED}"/$(get_libdir)/ &&
#ln -s ${PN}.so.5 "${ED}"/$(get_libdir)/${PN}.so &&
#mv -n linear.h "${ED}"/usr/include/ &&
#printf %s\\n "Install: ${PROGS} ${PN} ftppr mycrypt pop3p bin/"
