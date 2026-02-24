#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-21 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/x11-misc/notification-daemon/notification-daemon-3.20.0-r1.ebuild

# TODO: add static-bin build (--disable-shared,LIBS=,NOTIFICATION_DAEMON_LIBS)

EAPI=7

inherit install-functions gnome.org

DESCRIPTION="Notification daemon"
HOMEPAGE="https://gitlab.gnome.org/GNOME/notification-daemon/"
LICENSE="GPL-2"
PN="notification-daemon"
PV="3.20.0"
SRC_URI="https://download.gnome.org/sources/notification-daemon/${PV%.*}/${PN}-${PV}.tar.xz"
IUSE="-static +shared -doc (+musl) +stest +strip"
DOCS="AUTHORS ChangeLog NEWS"

pkgins() { pkginst \
  "app-accessibility/at-spi2-atk  # for atk" \
  "app-accessibility/at-spi2-core  # for atk" \
  "app-text/libpaper  # required for cups (optional)" \
  "dev-libs/atk" \
  "dev-libs/expat  # for fontconfig or python bundled" \
  "dev-libs/fribidi  # for pango (required remove)" \
  "dev-libs/glib74" \
  "dev-libs/gobject-introspection74  # optional (+introspection)" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/pcre2  # optional (internal pcre glib-2.68.4)" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-2  # for pango (harfbuzz-11.*)" \
  "media-libs/libepoxy" \
  "media-libs/libjpeg-turbo3  # for gdk-pixbuf or bundled-libs" \
  "media-libs/libpng  # for pango or bundled-libs" \
  "media-libs/mesa  # required for libepoxy (opengl)" \
  "media-libs/tiff  # for gdk-pixbuf" \
  "sys-apps/dbus  # for atk" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/gettext-tiny  # required for .desktop file generic" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # testing" \
  "sys-libs/musl" \
  "sys-libs/zlib  # for glib or bundled-libs" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # optional (cairo1)" \
  "x11-libs/gdk-pixbuf" \
  "x11-libs/gtk3" \
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
  || die "Failed install build pkg depend... error"
}

src_configure() {
  filter-flags -DNDEBUG  #FIX: NDEBUG redefined

  ./configure \
    --prefix="/usr" \
    --libexecdir="/usr/libexec" \
    --datadir="/usr/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"
}

src_install() {
  make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error"

  insinto /usr/share/dbus-1/services
  #newins <<-EOF - org.freedesktop.Notifications.service

  cd "${ED}"/usr/share/dbus-1/services/

  cat > org.freedesktop.Notifications.service <<-EOF
[D-BUS Service]
Name=org.freedesktop.Notifications
Exec=/usr/libexec/notification-daemon
EOF
}
