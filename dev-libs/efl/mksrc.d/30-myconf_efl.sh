# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Enlightenment Foundation Libraries all-in-one package"
HOMEPAGE="https://www.enlightenment.org"
LICENSE="BSD-2 GPL-2 LGPL-2.1 ZLIB FTL NGINX-MIT" # with gnutls, no compat with openssl
IUSE="+bmp -dds -connman -debug -drm +eet -examples +fbcon +fontconfig -fribidi +gif -gles2"
IUSE="${IUSE} +glib +gnutls -gstreamer +harfbuzz -hyphen +ico -ibus -jpeg2k -libressl -libuv"
IUSE="${IUSE} -luajit -neon -nls +opengl +pdf -physics -postscript -ppm -psd -pulseaudio"
IUSE="${IUSE} -raw -scim +sdl +sound -static-libs +svg -system-lz4 -systemd -tga +tiff -tslib"
IUSE="${IUSE} -unwind -v4l -valgrind -vlc -vnc -wayland +webp +X -xcf -xim -xine +xpm +xpresent -zeroconf"

# bug: required variable CXX to define <c++>
CXX="c++"
# bug: <ld: final link failed: bad value> | fix: <-no-pie>
CFLAGS="${CFLAGS/-no-pie } -fvisibility=hidden -fomit-frame-pointer"
CXXFLAGS="${CXXFLAGS/-no-pie } -fvisibility=hidden -fomit-frame-pointer"

MYCONF="${MYCONF}
 --disable-csharp-bindings
 --with-tests=none
 --enable-cserve
 --enable-image-loader-generic
 --enable-image-loader-jpeg
 --enable-image-loader-png
 --disable-libeeze
 --disable-libmount
 --enable-xinput22

 --disable-doc
 --disable-eglfs
 --disable-gesture
 --disable-gstreamer
 --disable-image-loader-tgv
 --disable-tizen
 --disable-wayland-ivi-shell

 $(use_enable 'bmp' image-loader-bmp)
 $(use_enable 'bmp' image-loader-wbmp)
 $(use_enable 'dds' image-loader-dds)
 $(use_enable 'drm')
 $(use_enable 'drm' elput)
 $(use_enable 'eet' image-loader-eet)
 $(use_enable 'examples' always-build-examples)
 $(use_enable 'fbcon' fb)
 $(use_enable 'fontconfig')
 $(use_enable 'fribidi')
 $(use_enable 'gif' image-loader-gif)
 $(use_enable 'gles2' egl)
 $(use_enable 'gstreamer' gstreamer1)
 $(use_enable 'harfbuzz')
 $(use_enable 'hyphen')
 $(use_enable 'ico' image-loader-ico)
 $(use_enable 'ibus')
 $(use_enable 'jpeg2k' image-loader-jp2k)
 $(use_enable 'libuv')
 $(use_enable !luajit lua-old)
 $(use_enable 'neon')
 $(use_enable 'nls')
 $(use_enable 'pdf' poppler)
 $(use_enable 'physics')
 $(use_enable 'postscript' spectre)
 $(use_enable 'ppm' image-loader-pmaps)
 $(use_enable 'psd' image-loader-psd)
 --disable-pulseaudio
 $(use_enable 'raw' libraw)
 $(use_enable 'scim')
 $(use_enable 'sdl')
 $(use_enable 'sound' audio)
 $(use_enable 'static-libs' static)
 $(use_enable 'svg' librsvg)
 --disable-liblz4
 --disable-systemd
 $(use_enable 'tga' image-loader-tga)
 $(use_enable 'tiff' image-loader-tiff)
 $(use_enable 'tslib')
 $(use_enable 'v4l' v4l2)
 --disable-valgrind
 $(use_enable 'vlc' libvlc)
 $(use_enable 'vnc' vnc-server)
 --disable-wayland
 $(use_enable 'webp' image-loader-webp)
 $(use_enable 'xcf')
 $(use_enable 'xim')
 $(use_enable 'xine')
 $(use_enable 'xpm' image-loader-xpm)
 $(use_enable 'xpresent')
 $(use_enable 'zeroconf' avahi)

 --with-crypto=$(usex 'gnutls' gnutls none)
 --with-glib=$(usex 'glib')
 --with-js=none
 --with-net-control=$(usex 'connman' connman none)
 --with-profile=$(usex 'debug' debug release)
 --with-x11=$(usex 'X' xlib none)

 $(use_with 'X' x)
"

test "X${USER}" != 'Xroot' || return 0

# Upstream still doesnt offer a configure flag. #611108
if ! use 'unwind'; then
  sed -i -e 's:libunwind libunwind-generic:xxxxxxxxxxxxxxxx:' \
  configure || die "Sedding configure file with unwind fix failed."
fi
