#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-28 01:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/guru/net-libs/kcgi/kcgi-0.13.4.ebuild

EAPI=8

inherit flag-o-matic toolchain-funcs static

DESCRIPTION="Minimal CGI library for web applications"
HOMEPAGE="https://kristaps.bsd.lv/kcgi/"
LICENSE="ISC"
PN="kcgi"
PV="0.13.4"
SRC_URI="https://kristaps.bsd.lv/${PN}/snapshots/${PN}-${PV}.tgz"
IUSE="-debug +static-libs -test +shared -man -doc (+musl) +stest +strip"
TARGET_INST=
PROG="sbin/kfcgi"

pkgins() { pkginst \
  "app-crypt/libmd" \
  "dev-build/bmake" \
  "dev-libs/libbsd" \
  "dev-util/pkgconf" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib  # bundled" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # bug 921120
  sed "/CFLAGS=/s/ -g / /" -i configure || die
}

src_configure() {
  export MAKESYSPATH="/usr/share/mk/bmake"

  tc-export CC AR
  append-cppflags $(usex debug "-DSANDBOX_SECCOMP_DEBUG" "-DNDEBUG")

  # Recommended by upstream
  append-cflags $(pkg-config --cflags libbsd-overlay)
  append-ldflags $(pkg-config --libs libbsd-overlay)

  # note: not an autoconf configure script
  ./configure \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    PREFIX="${EPREFIX%/}" \
    INCLUDEDIR="/usr/include" \
    MANDIR="${EPREFIX%/}/usr/share/man" \
    LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    SBINDIR="${EPREFIX%/}/sbin" \
    || die "configure... error"
}

src_compile() {
  bmake || die "Failed make build"
}

src_install() {
  bmake DESTDIR="${ED}" \
    DATADIR="${EPREFIX%/}/usr/share/doc/${PN}-${PV}/examples" \
    install || die "make install... error"

  : docompress -x /usr/share/doc/${PN}-${PV}/examples || true
  : einstalldocs || true

  # bug 921121
  use 'static-libs' || { find "${ED}"/$(get_libdir) -name "*.a" -delete || die; }
}
