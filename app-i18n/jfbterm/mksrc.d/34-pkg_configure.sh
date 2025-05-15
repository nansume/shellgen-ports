#!/bin/sh
# +static -static-libs -shared +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://gitweb.gentoo.org/repo/gentoo.git/plain/app-i18n/jfbterm/jfbterm-0.4.7-r4.ebuild?id=${HASH}

DESCRIPTION="The J Framebuffer Terminal/Multilingual Enhancement with UTF-8 support"
HOMEPAGE="http://jfbterm.sourceforge.jp/"
LICENSE="BSD"
IUSE="-debug +static -shared +nopie -doc (+musl) +stest +strip"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

#CC="gcc --static"
#export ACLOCAL="aclocal"

mv -n configure.in configure.ac || die

autoreconf --install

#ln -sf aclocal /bin/aclocal-1.4

./configure \
  CC="${CC}" \
  CXX="${CXX}" \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --disable-debug \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
