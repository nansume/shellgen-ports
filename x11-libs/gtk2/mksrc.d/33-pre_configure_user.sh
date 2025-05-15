#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit eutils flag-o-matic gnome2 install-functions

DESCRIPTION="Gimp ToolKit +"
HOMEPAGE="https://www.gtk.org/"
LICENSE="LGPL-2+"
IUSE="-aqua -cups -examples -introspection -test -vim-syntax -xinerama"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

local IFS="$(printf '\n\t') "

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

# Stop trying to build unmaintained docs, bug #349754, upstream bug #623150
strip_builddir SUBDIRS tutorial docs/Makefile.am docs/Makefile.in
strip_builddir SUBDIRS faq docs/Makefile.am docs/Makefile.in

# don't waste time building tests
strip_builddir SRC_SUBDIRS tests Makefile.am Makefile.in
strip_builddir SUBDIRS tests gdk/Makefile.am gdk/Makefile.in gtk/Makefile.am gtk/Makefile.in

if ! use 'examples'; then
  # don't waste time building demos
  strip_builddir SRC_SUBDIRS demos Makefile.am Makefile.in
fi
