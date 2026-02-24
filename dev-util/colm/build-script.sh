#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-22 15:00 UTC - last change
# Build with useflag: -static +static-libs +shared +lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-util/colm/colm-0.14.7-r4.ebuild

EAPI=8

inherit install-functions autotools flag-o-matic toolchain-funcs

DESCRIPTION="COmputer Language Manipulation"
HOMEPAGE="https://www.colm.net/open-source/colm/"
LICENSE="MIT"
PN="colm"
PV="0.14.7"
SRC_URI="https://www.colm.net/files/${PN}/${PN}-${PV}.tar.gz"
IUSE="-doc -static +static-libs +shared (+musl) +stest +strip"
PATCHES="
  ${FILESDIR}/${PN}-0.14.7-drop-julia-check.patch
  ${FILESDIR}/${PN}-0.14.7-solaris.patch
  # https://bugs.gentoo.org/927974
  ${FILESDIR}/${PN}-0.14.7-slibtool.patch
"

pkgins() { pkginst \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/gettext-tiny  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # bug #733426
  sed -i -e 's/(\[ASCIIDOC\], \[asciidoc\], \[asciidoc\]/S([ASCIIDOC], [asciidoc asciidoctor]/' configure.ac || die

  # Respect CC/CXX (bug #766069), we also omit CFLAGS here because
  # it seems to crash with some combinations and the software is fragile
  # (bug #883993).
  sed -i -e "s|gcc|$(tc-getCC)|" src/main.cc || die
  sed -i -e "s|gcc|$(tc-getCC)|" test/colm.d/gentests.sh || die
  sed -i -e "s|g++|$(tc-getCXX)|" test/colm.d/gentests.sh || die

  # Test fails w/ modern C (bug #944324)
  rm test/colm.d/ext1.lm || die

  # https://github.com/adrian-thurston/colm/issues/134
  sed -e 's|^data_DATA =|pkgdata_DATA =|' -i src/cgil/Makefile.am || die
  #sed -e 's|^DATA = $(data_DATA)$|DATA = $(pkgdata_DATA)|' -i src/cgil/Makefile.in || die

  eautoreconf
}

src_configure() {
  # We need to be careful with both ragel and colm.
  # See bug #858341, bug #883993 bug #924163.
  filter-lto
  append-flags -fno-strict-aliasing

  # bug #944324
  append-cflags -std=gnu89

  # bug #924163
  append-lfs-flags

  econf $(use_enable 'doc' manual)
}

src_test() {
  use 'test' || return 0
  # Build tests
  #default

  # Run them (and make sure we use just-built libraries, bug #941565)
  local LD_LIBRARY_PATH="${S}/src/.libs:${S}/src:${LD_LIBRARY_PATH}"
  export LD_LIBRARY_PATH

  cd test || die
  ./runtests || die
}

src_install() {
  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  # https://github.com/adrian-thurston/colm/issues/134
  #mv "${ED}"/usr/share/runtests -t "${ED}"/usr/share/${PN}/
  rm "${ED}"/usr/share/runtests

  # TIP: may be needed for static-libs, then remove it
  find "${ED}" -type f -name '*.la' -delete || die
}
