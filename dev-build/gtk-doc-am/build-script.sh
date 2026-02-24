#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-21 19:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/dev-build/gtk-doc-am/gtk-doc-am-1.34.0.ebuild

EAPI=8

inherit install-functions gnome.org

DESCRIPTION="Automake files from gtk-doc"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gtk-doc"
LICENSE="GPL-2+ FDL-1.1"
PN="gtk-doc-am"
SPN="gtk-doc"
PV="1.34.0"
SRC_URI="https://download.gnome.org/sources/gtk-doc/${PV%.*}/${SPN}-${PV}.tar.xz"
IUSE=""
BUILD_DIR="${WORKDIR}/${SPN}-${PV}"

pkgins() { :;}

src_configure() { :;}

src_compile() { :;}

src_install() {
  insinto /usr/share/aclocal
  doins buildsystems/autotools/gtk-doc.m4 || die "install... error"
}
