#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-19 22:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie +patch -doc -xstub -diet (+musl) -stest -strip +noarch

# https://github.com/openwrt/packages/archive/master.tar.gz  openwrt-community/packages/admin/muninlite/Makefile

DESCRIPTION="Munin node implemented in shell"
HOMEPAGE="https://github.com/munin-monitoring/muninlite"
LICENSE="GPL-2.0-or-later"
PN="muninlite"
PV="2.1.2"
SRC_URI="https://github.com/munin-monitoring/muninlite/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="-stest"
PATCH_URI="https://github.com/openwrt/packages/raw/master/admin/muninlite/patches"
PATCHES="
  ${FILESDIR}/001-ntpdate-fix-typo-on-graph-title.patch
  ${FILESDIR}/002-plugin-ntpdate-tolerate-multiple-NTP-servers-e.g.-in.patch
  ${FILESDIR}/003-Improve-df.patch
  ${FILESDIR}/004-Fix-previous-change.-The-key-for-config-and-values-w.patch
  ${FILESDIR}/100-netstat-drop-netstat-s-dep-by-using-proc-net-snmp-da.patch
  ${FILESDIR}/200-Allow-customizing-the-list-of-monitored-network-inte.patch
  ${FILESDIR}/201-Add-examples-for-config-with-INTERFACE_NAMES_OVERRID.patch
  ${FILESDIR}/202-Fix-parameter-not-set-error.patch
  ${FILESDIR}/203-Make-example-more-portable.patch
  ${FILESDIR}/204-Remove-example-code-as-requested.patch
"

pkgins() { pkginst \
  "dev-lang/perl  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_configure() { :;}
src_compile() { :;}

src_install() {
  make DESTDIR="${ED}/sbin/" install || die "make install... error"
  mkdir -m 0755 "${ED}"/etc/ "${ED}"/etc/munin/
  mkdir -m 0755 "${ED}"/etc/munin/plugins/ "${ED}"/etc/xinetd.d/
  mv -n muninlite.conf "${ED}"/etc/munin/
  cp -n "${PDIR%/}"/files/etc/xinetd.d/muninlite "${ED}"/etc/xinetd.d/
  sed -e 's|/usr/sbin/|/sbin/|' -i "${ED}"/etc/xinetd.d/muninlite
}
