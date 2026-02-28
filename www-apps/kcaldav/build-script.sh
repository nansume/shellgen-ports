#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-28 02:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=kcaldav

inherit static

DESCRIPTION="Simple, safe, minimal CalDAV server (CGI)"
HOMEPAGE="https://kristaps.bsd.lv/kcaldav/"
LICENSE="custom:BSD"
PN="kcaldav"
PV="0.2.5"
SRC_URI="https://kristaps.bsd.lv/kcaldav/snapshots/${PN}-${PV}.tgz"
IUSE="+static +static-libs -shared (+bundled) -doc (-diet) (+musl) +stest +strip"
_TARGET_INST=
_PROG="bin/${PN}"

pkgins() { pkginst \
  "app-crypt/libmd" \
  "dev-db/sqlite0" \
  "#dev-libs/dietlibc  #dietlibc1 # 0.34-x32 or 0.35-x86" \
  "dev-libs/expat" \
  "dev-libs/libbsd" \
  "dev-util/pkgconf" \
  "net-libs/kcgi" \
  "sys-devel/binutils9  # binutils6" \
  "sys-devel/gcc14  # gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"
}

# required: inherit static
_bundled_static_libs() {
  musl_standalone  # static-libs build bundle
}

src_configure() { :;}

src_compile() {
  ./configure PREFIX="/usr"
  cat >> Makefile.configure <<-EOF
CFLAGS += ${CFLAGS} $(pkg-config libbsd --cflags) \
 -include stdint.h -D_GNU_SOURCE -include errno.h
LDFLAGS += ${LDFLAGS} $(pkg-config libbsd --libs)
EOF
  make -j "$(nproc)" || die "Failed make build"
}

src_install() {
  make \
    DESTDIR="${ED}" \
    CGIPREFIX=/usr/libexec/kcaldav \
    HTDOCSPREFIX=/usr/share/kcaldav \
    install installcgi \
    || die "make install... error"

  # Fix path for manual pages
  install -dm755 "${ED}"/usr/share/
  mv "${ED}"/usr/man "${ED}"/usr/share/
  mv "${ED}"/usr/lib "${ED}"/$(get_libdir)
  mv "${ED}"/usr/bin -t "${ED}"/
}
