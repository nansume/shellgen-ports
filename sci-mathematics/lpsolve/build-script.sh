#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-18 20:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sci-mathematics/lpsolve/lpsolve-5.5.2.11-r2.ebuild

EAPI=8

inherit install-functions toolchain-funcs

DESCRIPTION="Mixed Integer Linear Programming (MILP) solver"
HOMEPAGE="https://sourceforge.net/projects/lpsolve/"
LICENSE="LGPL-2.1"
PN="lpsolve"
SPN="lp_solve"
PV="5.5.2.11"
SRC_URI="
  mirror://sourceforge/${PN}/${SPN}_${PV}_source.tar.gz
  http://data.gpo.zugaina.org/gentoo/sci-mathematics/${PN}/files/${PN}-${PV}-misc.patch
"
IUSE="+static +static-libs +shared -doc (+musl) +stest +strip"
PATCHES="${FILESDIR}/${PN}-5.5.2.11-misc.patch"
TARGET_INST=
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}_${PV%.*.*}"
PROG="bin/${SPN}"

pkgins() { pkginst \
  "sci-libs/colamd" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_configure() { :;}

src_compile() {
  tc-export AR CC RANLIB LD

  cd lpsolve55 || die
  sh -x ccc || die

  use 'static-libs' || { rm bin/ux*/liblpsolve55.a || die;}

  cd ../lp_solve || die
  sh -x ccc || die
}

src_install() {
  use 'doc' && einstalldocs

  dobin lp_solve/bin/ux*/lp_solve
  use 'shared' && dolib.so lpsolve55/bin/ux*/liblpsolve55.so
  use 'static-libs' && dolib.a lpsolve55/bin/ux*/liblpsolve55.a

  insinto /usr/include/lpsolve || die
  doins *.h
}
