#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-06-28 18:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie +patch -doc -xstub -diet -musl -stest -strip +noarch

# http://data.gpo.zugaina.org/gentoo/media-fonts/terminus-font/terminus-font-4.49.1-r2.ebuild
# https://crux.nu/ports/crux-3.8/contrib/console-font-terminus/Pkgfile
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=terminus-font-ll2-td1
# void-packages-1.0/srcpkgs/terminus-font/template

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="A clean fixed font for the console and X11"
HOMEPAGE="https://terminus-font.sourceforge.net/"
LICENSE="OFL-1.1 GPL-2"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C.UTF-8"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="4.20"
PV="4.49.1"
SRC_URI="ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/terminus-font-4.20.tar.gz"
SRC_URI="
  http://downloads.sourceforge.net/project/${PN}/${PN}-${PV%.*}/${PN}-${PV}.tar.gz
  https://aur.archlinux.org/cgit/aur.git/plain/fix-75-yes-terminus.patch?h=terminus-font-ll2-td1
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-a-like-o +center-tilde +distinct-l +otf +pcf-8bit +pcf-unicode +psf"
IUSE="${IUSE} -quote +ru-dv +ru-g +ru-i -ru-k -doc"
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
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
FONTDIR="/usr/share/fonts/terminus"

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
  "#app-alternatives/awk  # TODO: no needed, then remove it" \
  "#app-alternatives/gzip  # TODO: no needed, then remove it" \
  "app-crypt/libb2  # deps python (optional)" \
  "#dev-lang/perl  # For old version" \
  "dev-lang/python3-12" \
  "dev-libs/expat  # deps python" \
  "#media-fonts/font-util  # TODO: no needed, then remove it" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  "sys-libs/zlib  # FIX: unknown encoding hex" \
  "x11-apps/bdftopcf" \
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

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Upstream patches. Some of them are suggested to be applied by default
  # dv - de NOT like latin g, but like caps greek delta
  #      ve NOT like greek beta, but like caps latin B
  # ge - ge NOT like `mirrored` latin s, but like caps greek gamma
  # ka - small ka NOT like minimised caps latin K, but like small latin k

  use 'a-like-o'     && gpatch -p1 -E < "${BUILD_DIR}"/alt/ao2.diff
  use 'center-tilde' && gpatch -p1 -E < "${BUILD_DIR}"/alt/td1.diff
  use 'distinct-l'   && gpatch -p1 -E < "${BUILD_DIR}"/alt/ll2.diff
  use 'ru-i'         && gpatch -p1 -E < "${BUILD_DIR}"/alt/ij1.diff
  use 'ru-k'         && gpatch -p1 -E < "${BUILD_DIR}"/alt/ka2.diff
  use 'ru-dv'        && gpatch -p1 -E < "${BUILD_DIR}"/alt/dv1.diff
  use 'ru-g'         && gpatch -p1 -E < "${BUILD_DIR}"/alt/ge2.diff
  use 'quote'        && gpatch -p1 -E < "${BUILD_DIR}"/alt/gq2.diff

  #gpatch -p1 -E < "${PDIR%/}"/patches/terminus_ru-ao2.diff  # nowork
  gpatch -p1 -E < "${FILESDIR}"/fix-75-yes-terminus.patch

  # --otbdir=/usr/share/fonts/X11/misc
  # --psfdir=/usr/share/kbd/consolefonts
  # --x11dir=/usr/share/fonts/X11/misc
  # --x11dir=/usr/share/fonts/terminus
  # --x11dir=${EPREFIX%/}/${FONTDIR}

  ./configure \
    --prefix="/usr" \
    --otbdir="${EPREFIX%/}"/usr/share/fonts/misc \
    --psfdir="${EPREFIX%/}"/usr/share/consolefonts \
    --x11dir="${EPREFIX%/}"/usr/share/fonts/terminus \
    || die "configure... error"

  make -j "$(nproc)" \
    $(usex otf "otb" "") \
    $(usex pcf-8bit "pcf-8bit" "") \
    $(usex pcf-unicode "pcf" "") \
    $(usex psf "psf" "psf-vgaw" "") \
    || die "Failed make build"

  make DESTDIR="${ED}" CHECKDIR="${ED}" \
    $(usex otf "install-otb" "") \
    $(usex pcf-8bit "install-pcf-8bit" "") \
    $(usex pcf-unicode "install-pcf" "") \
    $(usex psf "install-psf install-psf-vgaw install-psf-ref" "") \
    || die "make install... error"

  #use 'otf' && FONT_SUFFIX=otb font_src_install
  mkdir -pm 0755 -- "${ED}"/usr/share/fontconfig/conf.avail/ "${ED}"/usr/share/fontconfig/conf.default/
  mv -n 75-yes-terminus.conf -t "${ED}"/usr/share/fontconfig/conf.avail/

  cd "${ED}/" || die "install dir: not found... error"

  for FONT in "usr/share/consolefonts/"*; do
    case ${FONT##*/} in 'ter-v32b.psf.gz') continue;; esac
    rm -v -- "${FONT}"
  done

  ln -s ../conf.avail/75-yes-terminus.conf usr/share/fontconfig/conf.default/75-yes-terminus.conf

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz