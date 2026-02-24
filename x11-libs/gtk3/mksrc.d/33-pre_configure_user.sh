#!/bin/sh
# -static +static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit eutils flag-o-matic gnome2 install-functions

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"
LICENSE="LGPL-2+"
IUSE="-aqua -broadway -cloudprint -colord -cups -examples -gtk-doc"
IUSE="${IUSE} +introspection -test -vim-syntax -wayland +X -xinerama"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

strip_builddir() {
  local rule=$1
  shift
  local directory=$1
  shift
  sed -e "s/^\(${rule} =.*\)${directory}\(.*\)$/\1\2/" -i $@ \
    || die "Could not strip director ${directory} from build."
}

if ! use 'test'; then
  # don't waste time building tests
  strip_builddir SRC_SUBDIRS testsuite Makefile.am Makefile.in
fi
if ! use 'examples'; then
  # don't waste time building demos
  strip_builddir SRC_SUBDIRS demos Makefile.am Makefile.in
  strip_builddir SRC_SUBDIRS examples Makefile.am Makefile.in
fi

MYCONF="${MYCONF}
 $(use_enable 'aqua' quartz-backend)
 $(use_enable 'broadway' broadway-backend)
 $(use_enable 'cloudprint')
 $(use_enable 'colord')
 --disable-cups
 $(use_enable 'gtk-doc')
 $(use_enable 'introspection')
 $(use_enable 'wayland' wayland-backend)
 $(use_enable 'X' x11-backend)
 $(use_enable 'X' xcomposite)
 $(use_enable 'X' xdamage)
 $(use_enable 'X' xfixes)
 $(use_enable 'X' xkb)
 $(use_enable 'X' xrandr)
 $(use_enable 'xinerama')
 --disable-papi
 --disable-man
 --with-xml-catalog=${EPREFIX}/etc/xml/catalog
 --libdir=${EPREFIX}/$(get_libdir)
 CUPS_CONFIG=${EPREFIX}/usr/bin/${CHOST}-cups-config
"

#test -x "/bin/perl" && autoreconf --install
