#!/bin/sh
# +static -static-libs -shared -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

DESCRIPTION="BNC (BouNCe) is used as a gateway to an IRC Server"
HOMEPAGE="http://gotbnc.com/"
LICENSE="GPL-2"
IUSE="-ssl"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed -e 's:./mkpasswd:/bin/bncmkpasswd:' -i bncsetup \
  || die 'failed to rename mkpasswd in bncsetup'

# bug #900076
eautoreconf

# bug #861374
append-flags -fno-strict-aliasing
: filter-lto

./configure \
  --prefix="${EPREFIX}"/usr \
  --sysconfdir="${EPREFIX}"/etc \
  --localstatedir="${EPREFIX}"/var/lib \
  --datadir="${EPREFIX}"/usr/share \
  --mandir="${EPREFIX}"/usr/share/man \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_with 'ssl') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

# FIX: dietlibc/musl build... Failed
sed -e 's/u_short/unsigned short/' -i cmds.c server.c

make -j "$(nproc)" || die "Failed make build"
make DESTDIR="${ED}" install || die "make install... error"

mv -n "${ED}"/bin/mkpasswd "${ED}"/bin/bncmkpasswd \
  || die 'failed to rename the mkpasswd executable'
dodoc example.conf motd

rm -- Makefile*
