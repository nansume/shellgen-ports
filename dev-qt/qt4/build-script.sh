#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-05 09:00 UTC - last change
# Build with useflag: -static-libs +shared +ssl -glib -doc -xstub +musl +stest +strip +x32

# https://www.linuxfromscratch.org/blfs/view/7.8/x/qt4.html
# https://aur.archlinux.org/packages/qt4
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=qt4

export USER XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Cross-platform application development framework"
HOMEPAGE="https://www.qt.io"
LICENSE="custom / GPLv3 / LGPL / FDL"
IFS="$(printf '\n\t')"
#NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
XPN="qt-everywhere-opensource-src"
XPN="${6:-${XPN:?}}"
PV="4.8.7"
SRC_URI="
  https://download.qt-project.org/official_releases/qt/4.8/${PV}/${XPN}-${PV}.tar.gz
  https://download.kde.org/stable/qtwebkit-2.3/2.3.4/src/qtwebkit-2.3.4.tar.gz
  http://shellgen.mooo.com/pub/distfiles/patch/qt-4.8.7/qt464-iconv.patch
  https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtcore/files/qtcore-4.8.5-honor-ExcludeSocketNotifiers-in-glib-event-loop.patch?id=c6166ef6dd2a63d28e45478d25b5ba9b165eeae4 -> qtcore-4.8.5-honor-ExcludeSocketNotifiers-in-glib-event-loop.patch
  https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtcore/files/qtcore-4.8.5-qeventdispatcher-recursive.patch?id=c6166ef6dd2a63d28e45478d25b5ba9b165eeae4 -> qtcore-4.8.5-qeventdispatcher-recursive.patch
  https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtcore/files/qtcore-4.8.7-libressl.patch?id=c6166ef6dd2a63d28e45478d25b5ba9b165eeae4 -> qtcore-4.8.7-libressl.patch
  https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-qt/qtcore/files/qtcore-4.8.7-moc.patch?id=c6166ef6dd2a63d28e45478d25b5ba9b165eeae4 -> qtcore-4.8.7-moc.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtcore-4.8.7/qtcore-4.8.7-fix-socklent-for-musl.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtgui-4.8.7/qtgui-4.7.3-cups.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtgui-4.8.7/qtgui-4.8.5-disable-gtk-theme-check.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtgui-4.8.7/qtgui-4.8.5-qclipboard-delay.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtscript-4.8.7/4.8.6-javascriptcore-x32.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtwebkit-4.10.4/4.10.4-gcc5.patch
  http://shellgen.mooo.com/pub/distfiles/patch/qtwebkit-4.10.4/4.10.4-use-correct-icu-typedef.patch
  https://aur.archlinux.org/cgit/aur.git/plain/qt4-gcc6.patch?h=qt4 -> qt4-gcc6.patch
  https://aur.archlinux.org/cgit/aur.git/plain/qt4-gcc8.patch?h=qt4 -> qt4-gcc8.patch
  https://raw.githubusercontent.com/metatoaster/qt4-pld-linux-patchset/master/gcc9-qforeach.patch
  https://aur.archlinux.org/cgit/aur.git/plain/qt4-gcc11.patch?h=qt4 -> qt4-gcc11.patch
  https://aur.archlinux.org/cgit/aur.git/plain/disable-sslv3.patch?h=qt4 -> disable-sslv3.patch
  https://aur.archlinux.org/cgit/aur.git/plain/fix_jit.patch?h=qt4 -> fix_jit.patch
  https://aur.archlinux.org/cgit/aur.git/plain/qt4-icu59.patch?h=qt4 -> qt4-icu59.patch
  https://aur.archlinux.org/cgit/aur.git/plain/qt4-openssl-1.1.patch?h=qt4 -> qt4-openssl-1.1.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static-libs +shared (+musl) +stest (-test) +strip"
# qtcore4
IUSE="${IUSE} -rpath -doc +glib +iconv -icu +ipv6 -libressl +qt3support +ssl -xstub"
# qtdeclarative4
IUSE="${IUSE} +accessibility -qt3support -webkit"
# qtgui4
IUSE="${IUSE} +accessibility -cups -egl +glib -gtkstyle +mng -nas -nis +qt3support +tiff -trace +xinerama +xv"
# qtscript4
IUSE="${IUSE} +jit"
# qtwebkit4
IUSE="${IUSE} -debug +gstreamer"
# reorder
IUSE="${IUSE} +x11 +zlib +gif +dbus +icu +qtgui +qtscript +jit +qtxmlpatterns +qtwebkit +oldwebkit"
IUSE="${IUSE} +phonon +mmx +sse +sse2 -accessibility -egl +opengl +sqlite +svg +webkit +qt3support +glib"
IUSE="${IUSE} +qml +qtdeclarative +fontconfig +x11raster -embedded +cups +qtmultimedia +gstreamer"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
ED=${INSTALL_DIR}
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${XPN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PATCH="patch"

if test "X${USER}" != 'Xroot'; then
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

. "${PDIR%/}/etools.d/"build-functions

chroot-build || die "Failed chroot... error"

pkginst \
  "app-misc/ca-certificates  # qtwebkit4,ssl" \
  "dev-lang/perl  # optional" \
  "#dev-lang/python2  # qtwebkit4" \
  "#dev-lang/ruby24" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/icu59" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/glib-compat" \
  "#dev-libs/glib" \
  "#dev-libs/libressl-compat" \
  "#dev-libs/libxml2  # qtwebkit4" \
  "#dev-libs/libxslt  # qtwebkit4" \
  "#dev-libs/openssl-compat" \
  "dev-libs/openssl" \
  "#dev-perl/perl-digest-md5  # qtwebkit4" \
  "#dev-perl/perl-file-spec  # qtwebkit4" \
  "#dev-perl/perl-getopt-long  # qtwebkit4" \
  "#dev-util/gperf  # qtwebkit4" \
  "dev-util/pkgconf" \
  "media-libs/alsa-lib" \
  "media-libs/freetype  # fontconfig" \
  "media-libs/fontconfig" \
  "media-libs/giflib" \
  "#media-libs/gstreamer1  # qtwebkit4" \
  "#media-libs/gst-plugins-base1  # qtwebkit4" \
  "media-libs/mesa  # for opengl" \
  "net-print/cups" \
  "sys-apps/dbus" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "#sys-devel/bison2  # bison-3.6.4 for qtwebkit4" \
  "#sys-devel/flex  # qtwebkit4" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxdamage  # for ?opengl" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft" \
  "x11-libs/libxi" \
  "x11-libs/libxinerama  # optional" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence  # for ?opengl" \
  "x11-libs/libxv  # optional" \
  "x11-libs/libxt  # dbus" \
  "x11-libs/libxxf86vm  # for ?opengl" \
  "x11-libs/xtrans" \
  "x11-misc/util-macros" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  X=
  for F in *.tar.gz; do
    case ${F} in qtwebkit-*) X='webkit/'; mkdir -m 0755 "${PDIR%/}/${SRC_DIR}/${X}";; esac
    ${ZCOMP} -dc "${F}" | tar -C "${PDIR%/}/${SRC_DIR}/${X}" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${F} | tar -C ${PDIR%/}/${SRC_DIR}/${X} -xkf -"
  done

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  use 'oldwebkit' || {
    rm -r -- src/3rdparty/webkit/
    mv -n ../${X} src/3rdparty/${X}
  }

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"
  { test -x "/bin/g${PATCH}" && test ! -L "/bin/g${PATCH}" ;} && PATCH="/bin/g${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  patch -p1 -E < "${FILESDIR}/qtcore-4.8.5-honor-ExcludeSocketNotifiers-in-glib-event-loop.patch"
  patch -p0 -E < "${FILESDIR}/qtcore-4.8.5-qeventdispatcher-recursive.patch"
  use 'libressl' && patch -p0 -E < "${FILESDIR}/qtcore-4.8.7-libressl.patch"
  patch -p1 -E < "${FILESDIR}/qtcore-4.8.7-moc.patch"

  case $(tc-chost) in
    *-"musl"|*-"muslx32")
      patch -p1 -E < "${FILESDIR}/qtcore-4.8.7-fix-socklent-for-musl.patch"
    ;;
  esac
  case $(tc-chost) in
    *-"muslx32")
      # qfiledialog bug fix muslx32 overlay added fix from upstream
      patch -p1 -E < "${FILESDIR}/qt464-iconv.patch"
      # Recognize x32 and disable JIT
      patch -p1 -E < "${FILESDIR}/4.8.6-javascriptcore-x32.patch"
    ;;
  esac

  patch -p1 -E < "${FILESDIR}/qtgui-4.7.3-cups.patch"
  patch -p1 -E < "${FILESDIR}/qtgui-4.8.5-disable-gtk-theme-check.patch"
  patch -p1 -E < "${FILESDIR}/qtgui-4.8.5-qclipboard-delay.patch"
  # React to OpenSSL's OPENSSL_NO_SSL3 define
  patch -p1 -E < "${FILESDIR}/disable-sslv3.patch"
  # Fix linking step for JIT (Gentoo)
  patch -p0 -E < "${FILESDIR}/fix_jit.patch"
  # Fix building with ICU 59 (pld-linux)
  patch -p1 -E < "${FILESDIR}/qt4-icu59.patch"
  # Fix building with OpenSSL 1.1 (Debian + OpenMandriva)
  patch -p1 -E < "${FILESDIR}/qt4-openssl-1.1.patch"

  # for qtwebkit4
  use 'oldwebkit' || {
    cd "src/3rdparty/webkit/"
    ${PATCH} -p1 -E < "${FILESDIR}/4.10.4-gcc5.patch"
    patch -p1 -E < "${FILESDIR}/4.10.4-use-correct-icu-typedef.patch"
    cd "${BUILD_DIR}/"
  }

  # Fix building with GCC6 (Fedora)
  patch -p1 -E < "${FILESDIR}/qt4-gcc6.patch"
  # Fix building with GCC8.3
  patch -p0 -E < "${FILESDIR}/qt4-gcc8.patch"
  # Fix building with GCC9
  patch -p1 -E < "${FILESDIR}/gcc9-qforeach.patch"
  # Fix building with GCC11 (thx de-vries)
  use 'gcc11' && patch -p1 -E < "${FILESDIR}/qt4-gcc11.patch"

  # Add -xvideo to the list of accepted configure options
  sed -i -e 's:|-xinerama|:&-xvideo|:' configure || die

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    use 'static' && append-ldflags "-s -static --static"  # testing
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector $(usex 'nopie' -no-pie) $(usex 'nodebug' -g0) -march=$(arch | sed 's/_/-/')
  # fix bug for qtscript4 and no only (qt4 no support C++11 standard)
  #append-cxxflags -std=gnu++98 -fpermissive
  printf \\n%s "QMAKE_CXXFLAGS += -std=gnu++98" >> src/3rdparty/javascriptcore/JavaScriptCore/JavaScriptCore.pri
  printf \\n%s "QMAKE_CXXFLAGS += -std=gnu++98" >> src/plugins/accessible/qaccessiblebase.pri
  #append-cxxflags -std=gnu++03

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"

  # bug 172219
  sed \
    -e "s:CXXFLAGS.*=:CXXFLAGS=${CXXFLAGS} :" \
    -e "s:LFLAGS.*=:LFLAGS=${LDFLAGS} :" \
    -i qmake/Makefile.unix || die "sed qmake/Makefile.unix failed"

  # bug 427782
  sed -e '/^CPPFLAGS\s*=/ s/-g //' \
    -i qmake/Makefile.unix || die "sed CPPFLAGS in qmake/Makefile.unix failed"
  sed \
    -e 's/setBootstrapVariable QMAKE_CFLAGS_RELEASE/QMakeVar set QMAKE_CFLAGS_RELEASE/' \
    -e 's/setBootstrapVariable QMAKE_CXXFLAGS_RELEASE/QMakeVar set QMAKE_CXXFLAGS_RELEASE/' \
    -i configure || die "sed configure setBootstrapVariable failed"

  #sed -i "s|-O2|${CXXFLAGS}|" mkspecs/common/g++-base.conf
  #sed -i "s|-O2|${CXXFLAGS}|" mkspecs/common/gcc-base.conf
  sed -e "/^QMAKE_LFLAGS_RPATH/ s| -Wl,-rpath,||g" -i mkspecs/common/gcc-base-unix.conf
  #sed -i "/^QMAKE_LFLAGS\s/s|+=|+= ${LDFLAGS}|g" mkspecs/common/gcc-base.conf

  export QT4DIR="${BUILD_DIR}"
  export LD_LIBRARY_PATH="${QT4DIR}/lib:${LD_LIBRARY_PATH}"

  . runverb \
  ./configure \
    -bindir "${EPREFIX%/}/$(get_libdir)/qt4/bin" \
    -sysconfdir "${EPREFIX%/}/etc/xdg" \
    -libdir "${EPREFIX%/}/$(get_libdir)" \
    -plugindir "${EPREFIX%/}/$(get_libdir)/qt4/plugins" \
    -importdir "${EPREFIX%/}/$(get_libdir)/qt4/imports" \
    -headerdir "${INCDIR}/qt4" \
    -datadir "${DPREFIX}/share/qt4" \
    -translationdir "${DPREFIX}/share/qt4/translations" \
    -docdir "${DPREFIX}/share/doc/qt4" \
    -arch $(arch) \
    -platform 'linux-g++' \
    -opensource \
    -confirm-license \
    -release \
    -silent \
    -no-accessibility \
    $(usex !qtxmlpatterns -no-exceptions) \
    -system-proxies \
    $(usex 'qtxmlpatterns' -xmlpatterns -no-xmlpatterns) \
    $(usex 'qtmultimedia' -multimedia -no-multimedia) \
    $(usex 'qtmultimedia' -audio-backend -no-audio-backend) \
    $(usex !phonon -no-phonon) \
    -no-phonon-backend \
    $(usex !svg -no-svg) \
    $(usex !qtgui -no-gui) \
    $(usex 'qtwebkit' -webkit -no-webkit) \
    $(usex !qtscript -no-script) \
    $(usex !qtscript -no-scripttools) \
    $(usex 'jit' -javascript-jit) \
    $(usex 'qml' -declarative -no-declarative) \
    $(usex !gstreamer -DENABLE_VIDEO=0) \
    -no-declarative-debug \
    -qt-zlib \
    $(usex !gif -no-gif) \
    -qt-libtiff \
    -qt-libpng \
    -qt-libmng \
    -qt-libjpeg \
    $(usex !cups -no-cups) \
    -no-sql-db2 \
    -no-sql-ibase \
    -no-sql-sqlite2 \
    -no-sql-symsql \
    $(usex 'dbus' -dbus-linked -no-dbus) \
    -no-gtkstyle \
    -no-nas-sound \
    $(usex !opengl -no-opengl) \
    $(usex !egl -no-egl) \
    -no-openvg \
    $(usex !x11 -no-sm) \
    $(usex !x11 -no-xshape) \
    $(usex !x11 -no-xvideo) \
    $(usex !x11 -no-xsync) \
    $(usex !x11 -no-xinerama) \
    $(usex !x11 -no-xcursor) \
    $(usex !x11 -no-xfixes) \
    -xrandr \
    -xrender \
    $(usex !x11 -no-mitshm) \
    $(usex 'fontconfig' -fontconfig -no-fontconfig) \
    $(usex 'embedded' -qt-freetype -system-freetype) \
    $(usex !x11 -no-xinput) \
    $(usex !x11 -no-xkb) \
    -graphicssystem raster \
    $(usex !x11raster -runtimegraphicssystem) \
    $(usex !mmx -no-mmx) \
    -no-3dnow \
    $(usex !sse -no-sse) \
    $(usex !sse2 -no-sse2) \
    -no-sse3 \
    -no-ssse3 \
    -no-sse4.1 \
    -no-sse4.2 \
    -no-avx \
    -optimized-qmake \
    $(usex !icu '-nomake translations') \
    -nomake demos \
    -nomake examples \
    -nomake docs \
    $(usex 'glib' -glib -no-glib) \
    $(usex 'iconv' -iconv -no-iconv) \
    $(usex 'icu' -icu) \
    $(usex 'ssl' -openssl-linked -no-openssl) \
    $(usex 'qt3support' -qt3support -no-qt3support) \
    $(usex 'shared' -shared ) \
    $(usex 'static-libs' -static) \
    $(usex 'rpath' -rpath -no-rpath) \
    || die "configure... error"

  make -j "$(nproc)" \
    CC="${CC}" \
    CXX="${CXX}" \
    $(test -n "${LDFLAGS}" && printf %s "LDFLAGS=${LDFLAGS}") \
    || die "Failed make build"

  . runverb \
  make INSTALL_ROOT="${ED}" install || die "make install... error"

  # install missing icons and desktop files
  install -D -m644 src/gui/dialogs/images/qtlogo-64.png \
    "${ED}"/usr/share/icons/hicolor/64x64/apps/qt4logo.png
  install -D -m644 tools/assistant/tools/assistant/images/assistant.png \
    "${ED}"/usr/share/icons/hicolor/32x32/apps/assistant-qt4.png
  install -D -m644 tools/assistant/tools/assistant/images/assistant-128.png \
    "${ED}"/usr/share/icons/hicolor/128x128/apps/assistant-qt4.png
  install -D -m644 tools/designer/src/designer/images/designer.png \
    "${ED}"/usr/share/icons/hicolor/128x128/apps/designer-qt4.png

  for icon in tools/linguist/linguist/images/icons/linguist-*-32.png; do
    size=$(printf ${icon##*/} | cut -d- -f2)
    install -D -m644 ${icon} "${ED}"/usr/share/icons/hicolor/${size}x${size}/apps/linguist-qt4.png
  done

  install -D -m644 tools/qdbus/qdbusviewer/images/qdbusviewer.png \
    "${ED}"/usr/share/icons/hicolor/32x32/apps/qdbusviewer-qt4.png
  install -D -m644 tools/qdbus/qdbusviewer/images/qdbusviewer-128.png \
    "${ED}"/usr/share/icons/hicolor/128x128/apps/qdbusviewer-qt4.png

  cd "${ED}/" || die "install dir: not found... error"

  #mkdir -m 0755  "usr/share/applications/"
  #install -m644 \
  #  "${FILESDIR}"/assistant-qt4.desktop \
  #  "${FILESDIR}"/designer-qt4.desktop \
  #  "${FILESDIR}"/linguist-qt4.desktop \
  #  "${FILESDIR}"/qtconfig-qt4.desktop \
  #  "${FILESDIR}"/qdbusviewer-qt4.desktop \
  #  "usr/share/applications/"

  # Useful symlinks for cmake and configure scripts
  mkdir -m 0755 "bin/"
  for b in $(get_libdir)/qt4/bin/*; do
    ln -s "/$(get_libdir)/qt4/bin/${b##*/}" bin/${b##*/}-qt4
  done

  # Fix wrong libs path in pkgconfig files
  #find "$(get_libdir)/pkgconfig" -type f -name '*.pc' -exec perl -pi -e "s, -L${srcdir}/?\S+,,g" {} \;

  # Fix wrong bins path in pkgconfig files
  #find "$(get_libdir)/pkgconfig" -type f -name '*.pc' -exec sed -i "s|/bin/|/$(get_libdir)/qt4/bin/|g" {} \;

  find "$(get_libdir)/pkgconfig" -type f -name '*.pc' -exec sed -i '1s|^prefix=.*|prefix=|' {} \;

  find "$(get_libdir)/pkgconfig" -type f -name '*.pc' -exec \
    sed -i "/^Libs.private: / s| -L/usr/X11R6/lib | -L/$(get_libdir) |" {} \;

  find "$(get_libdir)/pkgconfig" -type f -name '*.pc' -exec \
    sed -i "/^Libs.private: / s| -L${BUILD_DIR}/lib | -L/$(get_libdir) |g" {} \;

  # Fix wrong path in prl files
  #find "$(get_libdir)" -type f -name '*.prl' -exec sed -i '/^QMAKE_PRL_BUILD_DIR/d;s/\(QMAKE_PRL_LIBS =\).*/\1/' {} \;

  find "$(get_libdir)" -type f -name '*.prl' -exec \
    sed -i "/^QMAKE_PRL_LIBS = / s| -L/usr/X11R6/lib | -L/$(get_libdir) |" {} \;

  find "$(get_libdir)" -type f -name '*.prl' -exec \
    sed -i "/^QMAKE_PRL_LIBS = / s| -L${BUILD_DIR}/lib | -L/$(get_libdir) |g" {} \;

  # The TGA plugin is broken (FS#33568)
  rm -- "$(get_libdir)/qt4/plugins/imageformats/libqtga.so"

  for X in usr/share/qt4/mkspecs/*; do
    test -d "${X}" || continue
    case ${X} in
      */common|*/features|*/linux-g++|*/linux-llvm|*/linux-lsb-g++|*/qws) continue;;
    esac
    rm -r -- "${X}"
  done

  use 'static-libs' || find "$(get_libdir)/" -name '*.la' -delete || die

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${PN} pkg-create-cgz
