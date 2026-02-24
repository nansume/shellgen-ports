#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-20 17:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-apps/gawk/gawk-5.3.2.ebuild

EAPI=8

inherit install-functions toolchain-funcs flag-o-matic

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="https://www.gnu.org/software/gawk/gawk.html"
LICENSE="GPL-3+ pma? ( AGPL-3+ )"
PV="5.3.2"
SRC_URI="http://ftp.gnu.org/gnu/gawk/${PN}-${PV}.tar.xz"
# The gawk docs claim MPFR support is "on parole" and may be removed,
# https://www.gnu.org/software/gawk/manual/html_node/MPFR-On-Parole.html
# however this is somewhat outdated information, see
# https://public-inbox.org/libc-alpha/202412190851.4BJ8psq4404509@freefriends.org/
IUSE="-mpfr -pma -nls -readline +static -static-libs -shared -doc (+musl) +stest +strip"

pkgins() { pkginst \
  "#dev-util/byacc  # bison (posix, buggy)" \
  "sys-apps/file" \
  "#sys-apps/gawk  # optional" \
  "sys-devel/binutils9" \
  "sys-devel/bison  # optional - recomended" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  use 'musl' && append-cppflags -D__GNU_LIBRARY__

  # Use symlinks rather than hardlinks, and disable version links
  sed \
    -e '/^LN =/s:=.*:= $(LN_S):' \
    -e '/install-exec-hook:/s|$|\nfoo:|' \
    -i Makefile.in doc/Makefile.in || die

  # bug #413327
  sed -e '/^pty1:$/s|$|\n_pty1:|' -i test/Makefile.in || die
}

src_configure() {
  # README says gawk may not work properly if built with non-Bison.
  # We already BDEPEND on Bison, so just unset YACC rather than
  # guessing if we need to do yacc.bison or bison -y.
  unset YACC

  AWK=$(tc-getAWK)  # It like AWK=/bin/awk
  printf %s\\n "AWK='${AWK}'"

  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libexec="$(libdir)/misc" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --infodir="${EPREFIX%/}"/usr/share/info \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-extensions \
    $(use_with 'mpfr') \
    $(use_enable 'nls') \
    $(use_enable 'pma') \
    $(use_with 'readline') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-rpath \
    || die "configure... error"
}

src_install() {
  # Automatic dodocs barfs
  rm -rf README_d || die

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  # Install headers
  insinto /usr/include/awk
  doins *.h
  rm "${ED}"/usr/include/awk/config.h || die
}
