#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-19 10:00 UTC - last change
# Build with useflag: +static +static-libs -shared +lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/app-admin/ulogd/ulogd-2.0.9.ebuild

# TODO: It support build against diet-libc, then make it here.

EAPI=8

inherit install-functions flag-o-matic linux-info readme.gentoo-r1 toolchain-funcs

DESCRIPTION="Userspace logging daemon for netfilter/iptables related logging"
HOMEPAGE="https://netfilter.org/projects/ulogd/index.html"
LICENSE="GPL-2"
PN="ulogd"
PV="2.0.9"
SRC_URI="
  https://netfilter.org/projects/${PN}/files/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/app-admin/${PN}/files/${PN}.init
  http://data.gpo.zugaina.org/gentoo/app-admin/${PN}/files/${PN}.logrotate
"
IUSE="-dbi -doc -json -mysql -nfacct -nfct -nflog -pcap -postgres -selinux -sqlite"
IUSE="${IUSE} +static +static-libs -shared (+musl) (+diet) +stest +strip"

pkgins() { pkginst \
  "dev-util/pkgconf" \
  "net-firewall/nftables" \
  "#net-libs/libnetfilter-conntrack  # nfct (required: v1.10.0)" \
  "#net-libs/libnetfilter-log  # nflog (it missing)" \
  "net-libs/libnfnetlink" \
  "sys-apps/file" \
  "sys-apps/gawk  # FIX: install-sh: Segmentation fault" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # Change default settings to:
  # - keep log files in /var/log/ulogd instead of /var/log;
  # - create sockets in /run instead of /tmp.
  sed -i \
    -e "s|var/log|var/log/${PN}|g" \
    -e 's|tmp|run|g' \
    ulogd.conf.in || die
}

src_configure() {
  append-lfs-flags

  ./configure \
    --prefix="/usr" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'dbi') \
    $(use_enable 'json') \
    $(use_enable 'nfacct') \
    $(use_enable 'nfct') \
    $(use_enable 'nflog') \
    $(use_enable 'mysql') \
    $(use_enable 'pcap') \
    $(use_enable 'postgres' pgsql) \
    $(use_enable 'sqlite' sqlite3) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"
}

src_compile() {
  make -j "$(nproc)" || die "Failed make build"

  if use 'doc'; then
    # Prevent access violations from bitmap font files generation.
    export VARTEXFONTS="${T}/fonts"
    emake -C doc
  fi
}

src_install() {
  use 'doc' && HTML_DOCS="doc/${PN}.html"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  find "${ED}" -name '*.la' -delete || die

  readme.gentoo_create_doc
  use 'doc' && doman ${PN}.8

  use 'doc' && dodoc doc/${PN}.dvi doc/${PN}.ps doc/${PN}.txt
  use 'mysql' && dodoc doc/mysql-*.sql
  use 'postgres' && dodoc doc/pgsql-*.sql
  use 'sqlite' && dodoc doc/sqlite3.table

  insinto /etc
  doins ${PN}.conf
  : fowners root:ulogd /etc/${PN}.conf  # unknown group
  fperms 640 /etc/${PN}.conf

  newinitd "${FILESDIR}/${PN}.init" ${PN}
  systemd_dounit "${FILESDIR}/${PN}.service"

  insinto /etc/logrotate.d
  newins "${FILESDIR}/${PN}.logrotate" ${PN}

  : diropts -o ulogd -g ulogd
  keepdir /var/log/ulogd

  use 'doc' || rm -v -r -- "${ED}"/usr/share/man/ "${ED}"/usr/
}
