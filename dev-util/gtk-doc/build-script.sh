#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-21 20:00 UTC - last change
# useflag: -static -static-libs -shared -lfs -nopie +patch -doc -xstub -diet +musl +stest -strip +noarch/+x32

# http://data.gpo.zugaina.org/gentoo/dev-util/gtk-doc/gtk-doc-1.34.0-r2.ebuild

DESCRIPTION="GTK+ Documentation Generator"
HOMEPAGE="https://gitlab.gnome.org/GNOME/gtk-doc"
LICENSE="GPL-2+ FDL-1.1"
PN="gtk-doc"
PV="1.34.0"
SRC_URI="https://download.gnome.org/sources/gtk-doc/${PV%.*}/${PN}-${PV}.tar.xz"
IUSE="-emacs -test"
PATCHES="
  # Remove global Emacs keybindings, bug #184588
  ${FILESDIR}/${PN}-1.8-emacs-keybindings.patch

  # https://gitlab.gnome.org/GNOME/gtk-doc/-/issues/150
  ${FILESDIR}/${PN}-1.34.0-mkhtml-test.patch

  # https://gitlab.gnome.org/GNOME/gtk-doc/-/merge_requests/101
  ${FILESDIR}/${PN}-1.34.0-cmake4.patch # bug 957671
"

pkgins() { pkginst \
  "app-text/docbook-dsssl-stylesheets" \
  "app-text/docbook-sgml-dtd" \
  "app-text/docbook-xml-dtd43" \
  "app-text/docbook-xsl-stylesheets" \
  "dev-build/gtk-doc-am" \
  "dev-build/meson7  # build tool (here use modules)" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python3-8  # deps meson" \
  "dev-libs/expat  # deps meson,python" \
  "dev-libs/glib74" \
  "dev-libs/libffi  # deps meson" \
  "dev-libs/libxml2-1" \
  "dev-libs/libxslt" \
  "dev-libs/pcre2  # optional (internal pcre glib-2.68.4)" \
  "dev-python/py38-pygments" \
  "dev-util/itstool" \
  "dev-util/pkgconf" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/gettext-tiny" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps meson" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  # Requires the unpackaged Python "anytree" module
  sed -i -e '/mkhtml2/d' "${S}"/tests/meson.build || die
}

src_configure() {
  local emesonargs="
   -Dautotools_support=true
   -Dcmake_support=true
   -Dyelp_manual=true
   $(meson_use 'test' tests)
  "
  meson_src_configure ${emesonargs}
}

src_compile() {
  meson_src_compile
  use 'emacs' && elisp-compile tools/gtk-doc.el
}

src_install() {
  meson_src_install

  # The meson build system configures the shebangs to the temporary python
  # used during the build. We need to fix it.
  #sed -i -e 's:^#!.*python3:#!/bin/python3:' "${ED}"/bin/* || die
  python_fix_shebang "${ED}"/bin

  # Don't install this file, it's in gtk-doc-am now
  rm "${ED}"/usr/share/aclocal/gtk-doc.m4 || die "failed to remove gtk-doc.m4"
  rmdir "${ED}"/usr/share/aclocal || die

  if use 'emacs'; then
    elisp-install ${PN} tools/gtk-doc.el*
    elisp-site-file-install "${FILESDIR}/${SITEFILE}"
    readme.gentoo_create_doc
  fi
}

pkg_postinst() {
  if use 'emacs'; then
    elisp-site-regen
    readme.gentoo_print_elog
  fi
}

pkg_postrm() {
  use 'emacs' && elisp-site-regen
}
