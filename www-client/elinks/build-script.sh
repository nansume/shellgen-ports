#!/bin/sh
# Copyright (C) 2023-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2023-12-01 14:00 UTC - last change
# Build with useflag: +static -shared -fastmem -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/www-client/elinks/elinks-0.18.0.ebuild
# patches for gopher: https://slackbuilds.org/slackbuilds/15.0/network/elinks/patches/

# BUG: <+fastmem> with <+bittorent> too buggy while run-time when torrent add in downloads he to crash the browser.
# BUG: lua: lua hooks nil.

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX CPP PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Advanced and well-established text-mode web browser"
HOMEPAGE="http://elinks.or.cz/"
LICENSE="GPL-2"  # openssl with incompatible license!
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
PV="0.16.1.1"
PV="0.18.0"
SRC_URI="https://github.com/rkd77/elinks/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-gpm -mouse -x -X -test -trace -debug -backtrace"
IUSE="${IUSE} -lzma -bzip2 -zstd -brotli -guile +lua -perl -python -ruby -idn -xbel -xml -nls"
IUSE="${IUSE} -nntp -finger -samba +fastmem -openssl -tre -uri-rewrite -marks"
IUSE="${IUSE} +ipv6 +gnutls +ssl +cgi -quickjs -javascript"
IUSE="${IUSE} +ftp +bittorrent +gemini +gopher +unicode +zlib -sixel"
IUSE="${IUSE} +static -static-libs -shared -doc (-glibc) (+musl) +stest +strip"
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
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "#dev-lang/mujs" \
  "dev-lang/lua51  # lua54" \
  "dev-lang/perl  # required for autotools" \
  "dev-libs/gmp" \
  "dev-libs/libgcrypt" \
  "dev-libs/libgpg-error" \
  "dev-libs/libtasn1" \
  "dev-libs/libunistring" \
  "dev-libs/nettle" \
  "dev-util/pkgconf" \
  "#media-libs/libjpeg-turbo3  # deps: libsixel" \
  "#media-libs/libpng  # deps: libsixel" \
  "#media-libs/libsixel1  # BUG: nowork in virtual console (text mode)" \
  "net-libs/gnutls" \
  "sys-apps/file" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/bison  # FIX: error: bison... bad" \
  "sys-devel/gcc9" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools,libtoolize" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "#sys-libs/ncurses" \
  "sys-libs/zlib" \
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

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++" CPP="gcc -E"

  # <libs> for libpixel with static build
  use 'static' && { use 'sixel' && export LIBS="-lpng -ljpeg";}

  # BUG: <+fastmem> with <+bittorent> too buggy (crash)
  { use 'bittorrent' && use 'fastmem' ;} && {
    USE="${USE}${USE:+ }-fastmem"
    append-flags -ffast-math
  }

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  case $(tc-chost) in
    *'-muslx32')
      sed -e "s|\$(LD) -r -o|\$(LD) -m elf32_x86_64 -r -o|g" -i Makefile.lib
      #epatch ${FILESDIR}/musl-va_copy.patch
    ;;
  esac

  ./autogen.sh || exit && printf %s\\n './autogen.sh'
  . runverb \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${EPREFIX%/}"/usr/libexec \
    --datarootdir="${EPREFIX%/}"/usr/share \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-88-colors \
    --disable-256-colors \
    --disable-true-color \
    --enable-exmode \
    $(use_with 'openssl') \
    $(use_with 'gnutls') \
    --without-gssapi \
    $(use_enable 'cgi') \
    $(use_enable 'fastmem') \
    --enable-ftp \
    --disable-fsp \
    $(use_enable 'bittorrent') \
    $(use_enable 'nntp') \
    $(use_enable 'finger') \
    $(use_enable 'gopher') \
    $(use_enable 'gemini') \
    --disable-smb \
    --disable-sftp \
    $(use_with 'x') \
    --without-libev \
    --without-libevent \
    --disable-debug \
    --disable-backtrace \
    --enable-no-root \
    $(usex 'sixel' --with-libsixel) \
    $(use_with 'gpm') \
    $(usex 'idn' --without-idn2) \
    $(usex !marks --disable-marks) \
    --enable-leds \
    --enable-html-highlight \
    $(use_enable 'gpm' mouse) \
    $(use_with 'tre') \
    $(use_enable 'uri-rewrite') \
    $(use_enable 'xml' xbel) \
    --without-guile \
    --with-luapkg="$(getELUA)" \
    $(use_with 'perl') \
    --without-python \
    $(usex 'ruby' --with-ruby) \
    --without-quickjs \
    $(use_with 'javascript' mujs) \
    $(use_enable 'ipv6') \
    --without-brotli \
    $(use_with 'bzip2' bzlib) \
    --without-lzma \
    $(use_with 'zstd') \
    $(use_with 'static') \
    $(use_enable 'nls' gettext) \
    $(use_enable 'nls') \
    || die "configure... error"

  use 'static' && sed -e '/^LIBS =/ s/ -ldl//' -i Makefile.config

  make -j1 || die "Failed make build"
  make DESTDIR="${ED}" install || die "make install... error"
  printf %s\\n "make DESTDIR=${ED} install"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/" "usr/"

  use 'strip' && pkg-strip

  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz