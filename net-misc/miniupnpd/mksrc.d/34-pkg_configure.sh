#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs verify-sig install-functions

DESCRIPTION="MiniUPnP IGD Daemon"
HOMEPAGE="http://miniupnp.free.fr/ http://miniupnp.tuxfamily.org/"
LICENSE="BSD"
IUSE="+leasefile +igd2 +ipv6 +nftables +pcp-peer +portinuse -strict"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# fails without a default route
sed -i -e 's:EXTIF=.*:EXTIF=lo:' testgetifaddr.sh || die

./configure \
  --vendorcfg \
  $(usex 'igd2' --igd2) \
  $(usex 'ipv6' --ipv6) \
  $(usex 'leasefile' --leasefile) \
  $(usex 'portinuse' --portinuse) \
  $(usex 'pcp-peer' --pcp-peer) \
  $(usex 'strict' --strict) \
  --firewall=$(usex 'nftables' nftables iptables) \
  || die "configure... error"

# prevent gzipping manpage
sed -i -e '/gzip/d' Makefile || die

printf "Configure directory: ${PWD}/... ok\n"

sed -e 's:SBININSTALLDIR = .*:SBININSTALLDIR = $(PREFIX)/sbin:' -i Makefile

# By default, it builds a bunch of unittests that are missing wrapper
# scripts in the tarball
make V='0' -j"$(nproc)" CC="${CC}" STRIP=true miniupnpd || die "Failed make build"

make PREFIX=${ED} STRIP=true install || die "make install... error"

rm -- Makefile*
