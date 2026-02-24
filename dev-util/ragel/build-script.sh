#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-23 11:00 UTC - last change
# Build with useflag: -static +static-libs +shared +lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-util/ragel/ragel-7.0.4-r3.ebuild

# BUG: bin/colm -c -I /share -b rlhcGo -o rlhc.c /share/rlhc-go.lm
# TODO: `-I /share`   >>>  `-I /usr/share/colm`

EAPI=8

inherit install-functions autotools flag-o-matic

DESCRIPTION="Compiles finite state machines from regular languages into executable code"
HOMEPAGE="https://www.colm.net/open-source/ragel/"
LICENSE="MIT"
PN="ragel"
PV="7.0.4"
SRC_URI="https://www.colm.net/files/${PN}/${PN}-${PV}.tar.gz"
IUSE="-doc -static +static-libs +shared (+musl) +stest +strip"
PATCHES="
  ${FILESDIR}/${PN}-7.0.4-drop-julia-check.patch
  ${FILESDIR}/${PN}-7.0.4-r2-link-colm-properly.patch
"

pkgins() { pkginst \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-util/colm" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/gettext-tiny  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

  if [ ! -d "/share" ]; then
    mkdir -m 0755 /share/
    ln -s /usr/share/colm/*.lm /share/
  fi
}

src_prepare() {
  # Fix hardcoded search dir
  sed -i -e "s:\$withval/lib:\$withval/$(get_libdir):" configure.ac || die

  # Allow either asciidoctor or asciidoc
  # bug #733426
  sed -i -e 's/(\[ASCIIDOC\], \[asciidoc\], \[asciidoc\]/S([ASCIIDOC], [asciidoc asciidoctor]/' configure.ac || die
  eautoreconf
}

src_configure() {
  # We need to be careful with both ragel and colm.
  # See bug #858341, bug #883993 bug #924163.
  filter-lto
  append-flags -fno-strict-aliasing

  append-cppflags -I/usr/include/aapl

  econf \
   --with-colm="${EPREFIX%/}" \
   $(use_enable 'doc' manual)
}

src_install() {
  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  insinto /usr/share/vim/vimfiles/syntax
  doins ragel.vim

  # https://github.com/adrian-thurston/colm/issues/134
  mkdir -m 0755 "${ED}"/usr/share/${PN}/
  mv "${ED}"/usr/share/*.lm -t "${ED}"/usr/share/${PN}/

  # TIP: may be needed for static-libs, then remove it
  find "${ED}" -name '*.la' -delete || die
}
