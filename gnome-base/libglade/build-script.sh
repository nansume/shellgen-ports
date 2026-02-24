#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Library to construct graphical interfaces at runtime
# Homepage: https://library.gnome.org/devel/libglade/stable/
# License: LGPL-2
# Depends: <deps>
# Date: 2026-02-12 15:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/gnome-base/libglade/libglade-2.6.4-r5.ebuild

EAPI=8

inherit gnome2 multilib-minimal virtualx

PN="libglade"
PV="2.6.4"
SRC_URI="
  https://download.gnome.org/sources/libglade/${PV%.*}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/gnome-base/libglade/files/Makefile.in.am-2.4.2-xmlcatalog.patch
  http://data.gpo.zugaina.org/gentoo/gnome-base/libglade/files/${PN}-2.6.3-fix_tests-page_size.patch
  http://data.gpo.zugaina.org/gentoo/gnome-base/libglade/files/${PN}-${PV}-gold-glib-2.32.patch
  http://data.gpo.zugaina.org/gentoo/gnome-base/libglade/files/${PN}-${PV}-enable-extensions.patch
"
IUSE="(-static) +static-libs +shared -doc (+musl) +stest +strip"

pkgins(){ pkginst \
  "app-accessibility/at-spi2-core" \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "#dev-build/gtk-doc-am  # optional" \
  "dev-build/libtool6  # libtool6, required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python2  # BUG: python3 failed" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib69" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/libxml2-1  # for gettext" \
  "dev-libs/pcre  # optional (internal pcre glib-2.68.4)" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz  # [harfbuzz-11.*] for pango (TODO: remove it)" \
  "media-libs/libjpeg-turbo1  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps png,gtk2" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "#x11-libs/libxinerama  # optional" \
  "x11-libs/libxrender # for xft (optional)" \
  "x11-libs/pango" \
  "x11-libs/pixman  # for cairo" \
  "x11-libs/gdk-pixbuf  # reorder a sort" \
  "x11-libs/gtk2  # reorder a sort. gtk?" \
  || die "Failed install build pkg depend... error"
}

build(){
  # patch to stop make install installing the xml catalog
  # because we do it ourselves in postinst()
  patch -p1 -E < "${FILESDIR}"/Makefile.in.am-2.4.2-xmlcatalog.patch

  # patch to not throw a warning with gtk+-2.14 during tests, as it triggers abort
  patch -p1 -E < "${FILESDIR}/${PN}-2.6.3-fix_tests-page_size.patch"

  # Fails with gold due to recent changes in glib-2.32's pkg-config files
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-gold-glib-2.32.patch"

  # Needed for solaris, else gcc finds a syntax error in /usr/include/signal.h
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-enable-extensions.patch"

  sed 's/ tests//' -i Makefile.am Makefile.in || die "sed failed"

  # Deprecated macro that does nothing. Provided by gnome-base/gnome-common
  # but adding an additional bdep for this is silly.
  sed -i '/GNOME_COMMON_INIT/d' configure.in || die

  export am_cv_pathless_PYTHON=none

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"
}
