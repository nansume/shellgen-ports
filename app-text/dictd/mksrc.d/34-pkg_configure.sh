#!/bin/sh
# -static -static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Dictionary Client/Server for the DICT protocol"
HOMEPAGE="http://www.dict.org/ https://sourceforge.net/projects/dict/"
LICENSE="GPL-1+ GPL-2+"
IUSE="-dbi -judy -minimal -selinux -test"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}

local IFS=${NL}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

autoreconf -i

./configure \
  CC="${CC}" \
  LIBTOOL="${LIBTOOL}" \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --includedir="${INCDIR}" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  CFLAGS="${CFLAGS}" \
  CPPLAGS="${CPPLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
