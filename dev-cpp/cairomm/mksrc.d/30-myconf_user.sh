# http://data.gpo.zugaina.org/gentoo/dev-cpp/cairomm/cairomm-1.18.0.ebuild
# -static -static-libs +shared -nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="C++ bindings for the Cairo vector graphics library"
HOMEPAGE="https://cairographics.org/cairomm/ https://gitlab.freedesktop.org/cairo/cairomm"
LICENSE="LGPL-2+"
SLOT="1.16"
IUSE="-gtk-doc -test -X -nopie"

MESON_FLAGS="${MESON_FLAGS}
 -Dbuild-documentation=false
 -Dbuild-examples=false
 -Dbuild-tests=false
 -Dboost-shared=true
"