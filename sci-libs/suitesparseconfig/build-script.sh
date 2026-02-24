#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-18 13:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sci-libs/suitesparseconfig/suitesparseconfig-5.4.0.ebuild

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Common configurations for all packages in suitesparse"
HOMEPAGE="https://people.engr.tamu.edu/davis/suitesparse.html"
LICENSE="public-domain"
PN="suitesparseconfig"
PV="5.4.0"
SRC_URI="http://202.36.178.9/sage/${PN}-${PV}.tar.bz2"
SRC_URI="rsync://mirror.bytemark.co.uk/gentoo/distfiles/*/${PN}-${PV}.tar.bz2"
IUSE="+static-libs +shared -doc (+musl) +stest +strip"

pkgins() { pkginst \
  "net-misc/rsync  # for (mirror://) <mirror-fetch>" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

build() {
  ./configure \
    --prefix="/usr" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"
}

pre_package() {
  if ! use static-libs; then
    find "${ED}/$(get_libdir)/" -name "*.la" -print -delete || die
  fi
}
