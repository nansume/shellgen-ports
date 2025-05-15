#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-10-31 19:00 UTC - last change
# Build with useflag: -static -static-libs +shared -upx +qt5 -patch -doc -xstub -diet +musl +stest +strip +x32

#inherit build cmake-utils git-r3 pkg-export build-functions

export XPN PF PV WORKDIR BUILD_CHROOT PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CMAKE_PREFIX_PATH

DESCRIPTION="The PDF viewer and tools"
HOMEPAGE="https://www.xpdfreader.com"
LICENSE="|| ( GPL-2 GPL-3 ) i18n? ( BSD )"
DOCS="ANNOUNCE CHANGES README"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="4.04"
SRC_URI="
  http://dl.xpdfreader.com/old/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf-automagic.patch
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf-visibility.patch
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf-shared-libs.patch
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf-4.04-libpaper-2.patch
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf-4.04-font-paths.patch
  http://data.gpo.zugaina.org/gentoo/app-text/xpdf/files/xpdf.desktop
  https://dl.xpdfreader.com/xpdf-cyrillic.tar.gz
  https://dl.xpdfreader.com/xpdf-japanese.tar.gz -> xpdf-japanese-20201222.tar.gz
  https://dl.xpdfreader.com/xpdf-latin2.tar.gz
"
USE_BUILD_ROOT='0'
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-cmyk +cups -fontconfig -i18n +icons +libpaper +metric -opi +png +textselect +utils"
IUSE="${IUSE} -static -static-libs +shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:${DPREFIX}/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PN}

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
  "app-text/libpaper  # optiomal" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/fribidi  # deps: librsvg" \
  "dev-libs/glib-compat" \
  "dev-libs/icu-compat  # deps qt5base" \
  "dev-libs/libcroco  # deps: librsvg" \
  "dev-libs/libffi  # for glib" \
  "dev-libs/pcre  # deps: librsvg" \
  "dev-qt/qt5base  # not support in ver" \
  "dev-qt/qt5svg" \
  "dev-util/cmake" \
  "dev-util/pkgconf" \
  "gnome-base/librsvg  # for rsvg-convert" \
  "media-fonts/urw-fonts" \
  "media-libs/fontconfig" \
  "media-libs/freetype" \
  "media-libs/harfbuzz2  # deps: librsvg" \
  "media-libs/libpng" \
  "media-libs/mesa  # for opengl" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  "sys-libs/zlib  # deps: ${PN},png" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo  # deps: librsvg" \
  "x11-libs/gdk-pixbuf  # deps: librsvg" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libice" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libsm" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxdamage" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxrandr" \
  "x11-libs/libxrender" \
  "x11-libs/libxshmfence" \
  "x11-libs/libxxf86vm" \
  "x11-libs/pango  # deps: librsvg" \
  "x11-libs/pixman  # deps: librsvg" \
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

  inherit desktop xdg install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install/strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in "${FILESDIR}/"*".patch"; do
    test -f "${F}" && gpatch -p1 -E < "${F}"
  done

  sed \
    "s|/usr/local/etc|${EPREFIX%/}/etc|;s|/usr/local|${EPREFIX%/}/usr|" \
    -i doc/sample-xpdfrc || die

  if use 'i18n'; then
    sed -e "s|/usr/local|${EPREFIX%/}/usr|" -i "${WORKDIR}"/*/add-to-xpdfrc || die
  fi

  : xdg_environment_reset

  mkdir -m 0755 -- "${BUILD_DIR}/build/"
  cd "${BUILD_DIR}/build/" || die "builddir: not found... error"

  . runverb \
  cmake \
    -DCMAKE_INSTALL_PREFIX="${EPREFIX%/}/" \
    -DCMAKE_INSTALL_BINDIR="${EPREFIX%/}/bin" \
    -DCMAKE_INSTALL_LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    -DCMAKE_INSTALL_DATAROOTDIR="${DPREFIX}/share" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DA4_PAPER=$(usex 'metric') \
    -DNO_FONTCONFIG=$(usex 'fontconfig' off on) \
    -DNO_TEXT_SELECT=$(usex 'textselect' off on) \
    -DOPI_SUPPORT=$(usex 'opi') \
    -DSPLASH_CMYK=$(usex 'cmyk') \
    -DWITH_LIBPAPER=$(usex 'libpaper') \
    -DWITH_LIBPNG=$(usex 'png') \
    -DXPDFWIDGET_PRINTING=$(usex 'cups') \
    -DSYSTEM_XPDFRC="${EPREFIX}/etc/xpdfrc" \
    -DCMAKE_DISABLE_FIND_PACKAGE_Qt6Widgets="ON" \
    -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF) \
    -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON) \
    -DCMAKE_SKIP_INSTALL_RPATH=$(usex 'rpath' OFF ON) \
    -Wno-dev \
    .. || die "Failed cmake build"

  if use 'icons'; then
    cd "${BUILD_DIR}/"
    sizes="16 22 24 32 36 48 64 72 96 128 192 256 512"
    cd xpdf-qt
    mkdir $sizes
    for i in $sizes; do
      rsvg-convert xpdf-icon.svg -w $i -h $i -o $i/xpdf.png
    done
    cd "${BUILD_DIR}/build/"
  fi

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${BUILD_DIR}/"
  domenu "${FILESDIR}/xpdf.desktop"  # BUG: chmod: /sources/xpdf.desktop: Operation not permitted
  newicon -s "scalable" xpdf-qt/xpdf-icon.svg xpdf.svg
  if use 'icons'; then
    for i in $sizes; do
      doicon -s $i xpdf-qt/$i/xpdf.png
    done
    unset sizes
  fi

  mv -n doc/sample-xpdfrc "${ED}"/etc/xpdfrc

  if use 'utils'; then
    for d in "bin" "usr/share/man/man1"; do
      cd "${ED}/${d}/" || die
      for i in pdf*; do
        mv -n "${i}" "x${i}" || : die
      done
      cd "${OLDPWD}/" || : die
    done

    : einfo "PDF utilities were renamed from pdf* to xpdf* to avoid file collisions"
    : einfo "with other packages"
  else
    rm -rf "${ED}"/bin/pdf* \
     "${ED}"/usr/share/man/man1/pdf* \
     "${ED}"/$(get_libdir) || die
  fi

  if use 'i18n'; then
    for i in arabic chinese-simplified chinese-traditional cyrillic greek \
     hebrew japanese korean latin2 thai turkish; do
      insinto "/usr/share/xpdf/${i}"
      doins -r $(find -O3 "${WORKDIR}/xpdf-${i}" -maxdepth 1 -mindepth 1 \
       ! -name README ! -name add-to-xpdfrc || : die)

      cat "${WORKDIR}/xpdf-${i}/add-to-xpdfrc" >> "${ED}/etc/xpdfrc" || : die
    done
  fi

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/man/" "usr/"

  # simple test
  use 'stest' && { bin/${PROG} -V || : die "binary work... error";}

  ldd "bin/${PROG}" || die "library deps work... error"

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
