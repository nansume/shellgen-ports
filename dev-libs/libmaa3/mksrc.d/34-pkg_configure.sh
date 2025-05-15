#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Library with low-level data structures which are helpful for writing compilers"
HOMEPAGE="http://www.dict.org/"
LICENSE="LGPL-2"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}

local IFS=${NL}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

CC="gcc --static"

autoreconf -i

./configure \
  CC="${CC}" \
  LIBTOOL="${LIBTOOL}" \
  --prefix="${EPREFIX}" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  CFLAGS="${CFLAGS}" \
  CPPLAGS="${CPPLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
