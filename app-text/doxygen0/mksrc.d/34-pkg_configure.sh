#!/bin/sh
# +static +static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit eutils fdo-mime flag-o-matic toolchain-funcs install-functions

DESCRIPTION="Documentation system for most programming languages"
HOMEPAGE="http://www.doxygen.org/"
LICENSE="GPL-2"
IUSE="-clang -debug -doc -dot -doxysearch -qt4 -latex -sqlite"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# use CFLAGS, CXXFLAGS, LDFLAGS
export ECFLAGS="${CFLAGS}" ECXXFLAGS="${CXXFLAGS}" ELDFLAGS="${LDFLAGS}"
export AR="ar"

sed -i.orig -e 's:^\(TMAKE_CFLAGS_RELEASE\t*\)= .*$:\1= $(ECFLAGS):' \
  -e 's:^\(TMAKE_CXXFLAGS_RELEASE\t*\)= .*$:\1= $(ECXXFLAGS):' \
  -e 's:^\(TMAKE_LFLAGS_RELEASE\s*\)=.*$:\1= $(ELDFLAGS):' \
  -e "s:^\(TMAKE_CXX\s*\)=.*$:\1= ${CXX}:" \
  -e "s:^\(TMAKE_LINK\s*\)=.*$:\1= ${CXX}:" \
  -e "s:^\(TMAKE_LINK_SHLIB\s*\)=.*$:\1= ${CXX}:" \
  -e "s:^\(TMAKE_CC\s*\)=.*$:\1= ${CC}:" \
  -e "s:^\(TMAKE_AR\s*\)=.*$:\1= ${AR} cqs:" \
  tmake/lib/linux-g++/tmake.conf \
  tmake/lib/gnu-g++/tmake.conf \
  tmake/lib/linux-64/tmake.conf \
  || die

# Call dot with -Teps instead of -Tps for EPS generation - bug #282150
sed -i -e '/addJob("ps"/ s/"ps"/"eps"/g' src/dot.cpp || die

# fix pdf doc
sed -i.orig -e "s:g_kowal:g kowal:" \
  doc/maintainers.txt || die

sed -e "s/\$(DATE)/$(LC_ALL="C" LANG="C" date)/g" \
  -i Makefile.in || die #428280

./configure \
  --prefix="${EPREFIX}" \
  --install="install" \
  --flex="flex" \
  --bison="bison" \
  --static \
  --enable-langs "jp,ru" \
  --release \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
