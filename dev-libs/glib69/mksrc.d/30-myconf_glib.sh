# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="The GLib library of C routines"
HOMEPAGE="https://www.gtk.org/"
LICENSE="LGPL-2.1+"
IUSE="-dbus -debug -elf -fam -gtk-doc +mime -selinux -static-libs -sysprof -systemtap -test +utils -xattr"
EPREFIX=${EPREFIX:-$SPREFIX}

local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

# Don't build tests, also prevents extra deps, bug #512022
sed -i -e '/subdir.*tests/d' ./meson.build gio/meson.build glib/meson.build || die

# Don't build fuzzing binaries - not used
sed -i -e '/subdir.*fuzzing/d' meson.build || die

# Same kind of meson-0.50 issue with some installed-tests files; will likely be fixed upstream soon
sed -i -e '/install_dir/d' gio/tests/meson.build || die

# bug: undefined reference to <main>
CFLAGS=${CFLAGS/-no-pie }
CXXFLAGS=${CXXFLAGS/-no-pie }

MESON_FLAGS="${MESON_FLAGS}
 $(meson_feature 'debug' glib_debug)
 -Ddefault_library=$(usex 'static-libs' both shared)
 #-Druntime_dir=${EPREFIX}/run
 $(meson_feature 'selinux')
 $(meson_use 'xattr')
 #-Dlibmount=false
 -Dlibmount=disabled
 #-Dinternal_pcre=true
 -Dman=false
 $(meson_use 'systemtap' dtrace)
 $(meson_use 'systemtap')
 $(meson_feature 'sysprof')
 $(: meson_native_use_bool 'gtk-doc' gtk_doc)
 $(meson_use 'fam')
 $(meson_use 'test' tests)
 -Dinstalled_tests=false
 -Dnls=disabled
 -Doss_fuzz=disabled
 $(meson_feature 'elf' libelf)
 #-Dmultiarch=false
"
