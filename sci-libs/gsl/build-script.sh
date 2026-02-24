#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-18 20:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sci-libs/gsl/gsl-2.7.1-r3.ebuild

EAPI=8

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="The GNU Scientific Library"
HOMEPAGE="https://www.gnu.org/software/gsl/"
LICENSE="GPL-3+"
PN="gsl"
PV="2.7.1"
SRC_URI="
  mirror://gnu/${PN}/${PN}-${PV}.tar.gz
  https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${PN}-2.7-cblas.patch.bz2
  http://data.gpo.zugaina.org/gentoo/sci-libs/gsl/files/${PN}-2.7.1-configure-clang16.patch
  http://data.gpo.zugaina.org/gentoo/sci-libs/gsl/files/${PN}-2.7.1-test-tolerance.patch
"
IUSE="-cblas-external +deprecated -static +static-libs +shared -doc (+musl) +stest +strip"

pkgins() { pkginst \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-apps/gawk  # FIX: install-sh: Segmentation fault (awk busybox no-compat)" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

build() {
  bunzip2 -dc "${FILESDIR}"/${PN}-2.7-cblas.patch.bz2 | gpatch -p1 -E
  gpatch -p1 -E < "${FILESDIR}"/${PN}-2.7.1-configure-clang16.patch
  gpatch -p1 -E < "${FILESDIR}"/${PN}-2.7.1-test-tolerance.patch

  if use 'cblas-external'; then
    export CBLAS_LIBS="$(${PKG_CONFIG} --libs cblas)"
    export CBLAS_CFLAGS="$(${PKG_CONFIG} --cflags cblas)"
  fi

  if use 'deprecated'; then
    sed -e "/GSL_DISABLE_DEPRECATED/,+2d" -i configure.ac || die
  fi

  test -x "/bin/perl" && autoreconf --install

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_with 'cblas-external') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  find "${ED}/$(get_libdir)/" -name '*.la' -print -delete || die

  use 'doc' || rm -v -r -- ${ED}/usr/share/info/ ${ED}/usr/share/man/
}
