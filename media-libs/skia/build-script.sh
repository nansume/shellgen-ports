#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-24 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/4nykey/media-libs/skia/skia-113_p20230414.ebuild
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=skia-git

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX AR

DESCRIPTION="A complete 2D graphic library for drawing Text, Geometries and Images"
HOMEPAGE="https://skia.org"
LICENSE="BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
TAG="1195e70"  # 20230414
TAG="f406b70"  # 20250106
#TAG="5b56d9a"  # 20250415
PV="113p20230414"
PV="129p20250106"
#PV="129p20250415"
SRC_URI="mirror://githubcl/google/${PN}/tar.gz/${TAG} -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug -egl +ffmpeg +fontconfig +harfbuzz +icu +jpeg -lottie +opengl +png +static-libs"
IUSE="${IUSE} +truetype +webp +xml +shared +nopie -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${TAG}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}

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
  "dev-build/gn" \
  "dev-build/samurai  # alternative for ninja" \
  "dev-lang/python3-8  # build-tools" \
  "dev-libs/expat  # xml" \
  "dev-libs/glib74" \
  "dev-libs/icu76" \
  "dev-libs/pcre2  # for glib74" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-libs/fontconfig" \
  "media-libs/harfbuzz2-2" \
  "media-libs/libjpeg-turbo3" \
  "media-libs/libpng" \
  "media-libs/libwebp" \
  "media-libs/mesa  # opengl" \
  "media-video/ffmpeg7" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/m4  # required for ninja" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "x11-base/xorg-proto  # for opengl" \
  "x11-libs/libdrm  # for opengl" \
  "x11-libs/libpciaccess  # for opengl" \
  "x11-libs/libvdpau  # for opengl" \
  "x11-libs/libx11  # for opengl" \
  "x11-libs/libxau  # for opengl" \
  "x11-libs/libxcb  # for opengl" \
  "x11-libs/libxdamage  # for opengl" \
  "x11-libs/libxdmcp  # for opengl" \
  "x11-libs/libxext  # for opengl" \
  "x11-libs/libxfixes  # for opengl" \
  "x11-libs/libxrandr  # for opengl" \
  "x11-libs/libxrender  # for opengl" \
  "x11-libs/libxshmfence  # for opengl" \
  "x11-libs/libxxf86vm  # for opengl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++" AR="ar"
  MY_ARCH="$(arch | sed 's/_/-/')"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # https://chromium.googlesource.com/chromium/src/third_party/zlib
  # https://github.com/jtkukunas/zlib
  sed -e '/:zlib_x86/d' -i third_party/zlib/BUILD.gn

  mkdir -pm 0755 -- "_h/${PN}/"
  cd _h/${PN}/
  cp -a "${BUILD_DIR}"/include/* .
  cp -a "${BUILD_DIR}"/src/core/SkGeometry.h ./core/
  grep -rl '#include.*"include/' . | xargs sed '/#include/ s:"include/:":' -i

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

MYCONF="
 extra_cflags_c=[\"-mx32\", \"-msse2\", \"-O2\", \"-fno-stack-protector\", \"-no-pie\", \"-g0\", \"-march=${MY_ARCH}\",]
 extra_cflags_cc=[\"-mx32\", \"-msse2\", \"-O2\", \"-fno-stack-protector\", \"-no-pie\", \"-g0\", \"-march=${MY_ARCH}\",]
 ar=\"${AR}\"
 cc=\"${CC}\"
 cxx=\"${CXX}\"
 is_debug=$(usex debug true false)
 is_official_build=$(usex !debug true false)
 skia_use_system_expat=true
 skia_use_system_freetype2=true
 skia_use_system_harfbuzz=true
 skia_use_system_icu=true
 skia_use_system_libjpeg_turbo=true
 skia_use_system_libpng=true
 skia_use_system_libwebp=true
 skia_use_system_zlib=true
 skia_enable_spirv_validation=false
 skia_enable_pdf=false
 skia_use_dng_sdk=false
 is_component_build=true
 skia_enable_skottie=$(usex lottie true false)
 skia_use_egl=$(usex egl true false)
 skia_use_expat=$(usex xml true false)
 skia_use_ffmpeg=$(usex ffmpeg true false)
 skia_use_fontconfig=$(usex fontconfig true false)
 skia_use_freetype=$(usex truetype true false)
 skia_use_harfbuzz=$(usex harfbuzz true false)
 skia_enable_skshaper=$(usex harfbuzz true false)
 skia_use_gl=$(usex opengl true false)
 skia_use_icu=$(usex icu true false)
 skia_use_libjpeg_turbo_decode=$(usex 'jpeg' true false)
 skia_use_libjpeg_turbo_encode=$(usex 'jpeg' true false)
 skia_use_libpng_decode=$(usex 'png' true false)
 skia_use_libpng_encode=$(usex 'png' true false)
 skia_use_libwebp_decode=$(usex 'webp' true false)
 skia_use_libwebp_encode=$(usex 'webp' true false)
 skia_use_sfntly=false
 skia_use_wuffs=false
"

MYCONF="${MYCONF#[[:space:]]}"

  set -- gn gen --args="${MYCONF%[[:space:]]}" out/Release
  echo "$@"
  "$@" || die

  ninja -j "$(nproc)" -C "${BUILD_DIR}/out/Release" || die "Build... Failed"

  mkdir -pm 0755 -- "${ED}"/$(get_libdir)/ "${ED}"/usr/include/

  mv -n out/Release/*.so -t "${ED}"/$(get_libdir)/
  use 'static-libs' && mv -n out/Release/*.a -t "${ED}"/$(get_libdir)/
  mv -n _h/${PN} -t "${ED}"/usr/include/

  cd "${ED}/" || die "install dir: not found... error"

  ldd "$(get_libdir)"/lib*${PN}*.so || : die "library deps work... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz