#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-19 21:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/app-admin/radmind/radmind-1.15.4-r1.ebuild

# BUG:with opt `--enable-profiled` -> gprof libmcount.so - BUG: build-link _mcount error"

EAPI=8

inherit install-functions autotools flag-o-matic

DESCRIPTION="Command-line tools and server to remotely administer multiple Unix filesystems"
HOMEPAGE="https://github.com/Radmind https://sourceforge.net/projects/radmind/"
LICENSE="HPND"
PN="radmind"
PV="1.15.4"
SRC_URI="https://github.com/voretaq7/radmind/releases/download/${PN}-${PV}/${PN}-${PV}.tar.gz"
IUSE="-pam +zlib +static -static-libs -shared -doc (+musl) +stest +strip"
PATCHES="
  ${FILESDIR}/${PN}-1.7.0-gentoo.patch
  ${FILESDIR}/${PN}-1.14.1-glibc225.patch
  # 779664
  ${FILESDIR}/${PN}-1.15.4-autoreconf.patch
  ${FILESDIR}/${PN}-1.15.4-autoreconf-libsnet.patch
"
TARGET_INST=

pkgins() { pkginst \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool14  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-libs/gmp" \
  "dev-libs/openssl1" \
  "dev-util/pkgconf" \
  "net-libs/libnsl" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # We really don't want these
  # https://github.com/Radmind/radmind/pull/336
  # https://sourceforge.net/p/libsnet/patches/7/
  rm -f aclocal.m4 libsnet/aclocal.m4 || die

  eautoreconf
}

src_configure() {
  # bug #880375
  append-flags -std=gnu89

  # Fix for musl-libc
  sed -e 's/\([[:blank:]]\)u_int\([[:blank:]]\)/\1unsigned int\2/' -i list.c

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --disable-sasl \
    --enable-ssl \
    --disable-profiled \
    $(use_enable 'pam') \
    $(use_enable 'zlib') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"
}

src_install() {
  make DESTDIR="${ED}" install || die "make install... error"
  keepdir /var/radmind/cert /var/radmind/client
  keepdir /var/radmind/postapply /var/radmind/preapply
}
