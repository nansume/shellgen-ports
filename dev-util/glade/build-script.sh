#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: A user interface designer for GTK+ and GNOME
# Homepage: https://glade.gnome.org https://gitlab.gnome.org/GNOME/glade
# License: GPL-2+ FDL-1.1+
# Depends: <deps>
# Date: 2026-02-12 17:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs -nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-util/glade/glade-3.40.0-r3.ebuild

# BUG: for build static-libs required: dbus[static-libs] epoxy[static-libs] mesa[static-libs] - missing

inherit flag-o-matic gnome2 python-single-r1 meson optfeature virtualx

PN="glade"
PV="3.40.0"
SRC_URI="
  https://download.gnome.org/sources/${PN}/${PV%.*}/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/dev-util/glade/files/${PN}-3.14.1-doc-version.patch
  http://data.gpo.zugaina.org/gentoo/dev-util/glade/files/${PN}-3.40.0-webkitgtk-4.1.patch
"
IUSE="+X -gjs -gtk-doc +introspection -python -wayland -webkit"
IUSE="${IUSE} -help +locale -static -static-libs +shared -nopie -doc (+musl) +stest +strip"

pkgins() { pkginst \
  "app-accessibility/at-spi2-atk  # for atk" \
  "app-accessibility/at-spi2-core  # for atk" \
  "#app-crypt/libb2  # deps python" \
  "app-text/libpaper  # required for cups (optional)" \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools" \
  "#dev-build/cmake3  # it optional?" \
  "dev-build/meson7  # build tool" \
  "#dev-build/muon  # alternative for meson" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/perl  # required for autotools" \
  "dev-lang/python3-8  # deps meson" \
  "dev-libs/atk" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib74" \
  "dev-libs/gobject-introspection74" \
  "dev-libs/libffi  # deps meson" \
  "dev-libs/libxml2-1  # for gettext" \
  "dev-libs/pcre2  # optional (internal pcre glib-2.68.4)" \
  "#dev-python/pygobject  # use: +python" \
  "dev-util/itstool" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-2  # for pango" \
  "media-libs/libepoxy" \
  "media-libs/libjpeg-turbo3  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # required for libepoxy (opengl)" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/dbus  # for atk" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps meson" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/libdrm  # for mesa (optional)" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for mesa (optional)" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for mesa (optional)" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxcomposite" \
  "x11-libs/libxdamage" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "x11-libs/libxi" \
  "x11-libs/libxrandr  # for mesa (optional)" \
  "x11-libs/libxrender # for xft (optional)" \
  "x11-libs/libxshmfence  # for mesa (optional)" \
  "x11-libs/libxxf86vm  # for mesa (optional)" \
  "x11-libs/libxt  # for atk" \
  "x11-libs/libxtst  # deps at-spi2-atk" \
  "x11-libs/pango" \
  "x11-libs/pixman  # for cairo" \
  "x11-libs/gtk3" \
  || die "Failed install build pkg depend... error"
}


prepare() {
  . "${PDIR%/}/etools.d/"epython
  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"
}

build() {
  use 'X' || append-cppflags -DGENTOO_GTK_HIDE_X11
  use 'wayland' || append-cppflags -DGENTOO_GTK_HIDE_WAYLAND

  # To avoid file collison with other slots, rename help module.
  # Prevent the UI from loading glade:3's gladeui devhelp documentation.
  patch -p1 -E < "${FILESDIR}"/${PN}-3.14.1-doc-version.patch
  # https://gitlab.gnome.org/GNOME/glade/-/issues/555
  patch -p1 -E < "${FILESDIR}"/${PN}-3.40.0-webkitgtk-4.1.patch

  meson setup \
    -D prefix="/" \
    -D bindir="bin" \
    -D libdir="$(get_libdir)" \
    -D includedir="usr/include" \
    -D datadir="usr/share" \
    -D localedir="usr/share/locale" \
    -D wrap_mode="nodownload" \
    -D buildtype="release" \
    -D b_colorout="never" \
    -D man=$(usex 'man' true false) \
    -D b_pie="false" \
    -D gladeui=true \
    $(meson_feature 'gjs') \
    $(meson_feature 'python') \
    $(meson_feature 'webkit' webkit2gtk) \
    $(meson_use 'gtk-doc' gtk_doc) \
    $(meson_use 'introspection') \
    -D default_library=$(usex 'shared' both static) \
    -D prefer_static=$(usex 'static' true false) \
    -D strip=$(usex 'strip' true false) \
    "${BUILD_DIR}/build" "${BUILD_DIR}" \
    || die "meson setup... error"

  ninja -j "$(nproc)" -C "${BUILD_DIR}/build" || die "Build... Failed"

  DESTDIR="${ED}" meson install --no-rebuild -C "${BUILD_DIR}/build" || die "meson install... error"
}

pre_package() {
  grep '${prefix}' < $(get_libdir)/pkgconfig/${PN}ui-2.0.pc
  sed -e 's|${prefix}||' -i $(get_libdir)/pkgconfig/${PN}ui-2.0.pc

  #rm -vr -- "usr/share/help/" "usr/share/locale/"
}
