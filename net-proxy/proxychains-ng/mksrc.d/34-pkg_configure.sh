#!/bin/sh
# +static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="force any tcp connections to flow through a proxy (or proxy chain)"
HOMEPAGE="https://github.com/rofl0r/proxychains-ng/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
XPN=${PN}

export PN PV EPREFIX BUILD_DIR ED CC

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}; local PN=${PN%-*}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed -i "s/^\(LDSO_SUFFIX\).*/\1 = so.${PV}/" Makefile || die
sed -i "/LD_SONAME_FLAG=/ s/check_link_silent/:/" configure || die
mv completions/zsh/_proxychains4 completions/zsh/_proxychains || die

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX}"/bin \
  --sysconfdir="${EPREFIX}"/etc \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make V='0' -j"$(nproc)" || die "Failed make build"

make DESTDIR=${ED} install || die "make install... error"

rm -- Makefile

dobin ${PN}
dodoc AUTHORS README TODO

dolib.so lib${PN}.so.${PV}
dosym lib${PN}.so.${PV} /$(get_libdir)/lib${PN}.so.${PV%.*}
dosym lib${PN}.so.${PV} /$(get_libdir)/lib${PN}.so

insinto /etc
doins src/${PN}.conf

printf %s\\n "Install: ${XPN}"
