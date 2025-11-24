#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2024-10-20 15:00 UTC, 2025-07-05 19:00 UTC - last change
# Build with useflag: +static +static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +amd64

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=webkitfltk-static-git

# TIP: build for amd64 with static-libs, until that is emerge/be x32 support.

export XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX  #PYTHON

DESCRIPTION="Port of Webkit to FLTK 1.3"
HOMEPAGE="http://fifth-browser.sourceforge.net"
LICENSE="GPL-3"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}; PN=${PN%-static}
PV="0.5.1"
#PV="0.5.1-p20220906"
#XPV=${PV%.[0-9]}  # ver-0.5.1
XPV=${PV}
SRC_URI="
  mirror://sourceforge/fifth-browser/${PN}-${PV}.txz  #-> ${PN}-${PV}.tar.xz
  #https://github.com/clbr/webkitfltk/archive/v0.5.1.tar.gz -> ${PN}-${PV}.tar.gz
  #https://github.com/clbr/fifth/archive/v0.5.tar.gz -> ${PN}-0.5.tar.gz
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-1.patch
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-2.patch
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}-3.patch
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}_01-func-fix.diff
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}_02-gcc7-func-fix.diff
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}_03-makefile.diff
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}_04-webcore-makefile.diff
  #http://shellgen.mooo.com/pub/distfiles/patch/${PN}/${PN}_05-support-x32abi.diff
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs -shared -doc (+musl) +stest +strip"
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
ZCOMP="unxz"
#ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
#BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-master"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
#PYTHON="true"

# Required minimal 6GB free space!

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
  "app-misc/ca-certificates  # testing" \
  "dev-db/bdb6  # deps ruby (optional)" \
  "dev-db/sqlite0  # ?required (sqlite3)" \
  "dev-games/physfs" \
  "dev-lang/perl  # optional" \
  "dev-lang/python2  # for glib new version (python3 no-support)" \
  "dev-lang/ruby24  # support: ?ruby24 ?ruby25 ?ruby26" \
  "dev-libs/expat  # icu,freetype" \
  "dev-libs/glib57  # testing" \
  "dev-libs/gmp  # for ruby" \
  "dev-libs/icu59" \
  "dev-libs/libexecinfo  # it needed backtrace?" \
  "#dev-libs/libffi" \
  "dev-libs/libyaml  # deps ruby (optional)" \
  "dev-libs/libxml2" \
  "dev-libs/libxslt" \
  "dev-libs/openssl1  # deps ruby2* (optional)" \
  "dev-libs/openssl0  # needed for webkitfltk" \
  "dev-libs/urlmatch" \
  "dev-ruby/rubygems24  # deps ruby2* (optional)" \
  "dev-perl/digest-perl-md5" \
  "dev-util/gperf" \
  "media-libs/freetype" \
  "media-libs/fontconfig  # for fltk" \
  "media-libs/harfbuzz1" \
  "media-libs/libjpeg-turbo1" \
  "media-libs/libpng" \
  "net-misc/curl7" \
  "#sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/bison1" \
  "#sys-devel/bison0  # bison-3.6.4" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "#sys-devel/patch  # for patch with fuzz and offset." \
  "#sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  "#x11-base/xcb-proto" \
  "x11-base/xorg-proto" \
  "x11-libs/cairo" \
  "x11-libs/fltk" \
  "x11-libs/libice" \
  "x11-libs/libsm" \
  "x11-libs/libx11" \
  "x11-libs/libxau" \
  "x11-libs/libxcb" \
  "x11-libs/libxcursor" \
  "x11-libs/libxdmcp" \
  "x11-libs/libxext" \
  "x11-libs/libxfixes" \
  "x11-libs/libxft  # optional or --disable-xft" \
  "#x11-libs/libxinerama  # optional" \
  "x11-libs/libxrender # for xft (optional)" \
  "x11-libs/pixman" \
  "#x11-misc/util-macros" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  #ln -s ruby24 /bin/ruby
  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  { test -x "/bin/g${PATCH}" && test ! -L "/bin/g${PATCH}" ;} && PATCH="/bin/g${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-ldflags -Wl,--gc-sections
  append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
  append-cxxflags -std=gnu++11 -DNDEBUG -DENABLE_JIT=0  # FIX: gcc-5 or never version

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in "${FILESDIR}/"*".patch" "${FILESDIR}/"*".diff" "${PDIR}/patches/"*".diff"; do
    test -f "${F}" && patch -p1 -E < "${F}" #|| patch -p0 -E < ${F}
  done

  sed \
    -e "s| ENABLE_GEOLOCATION .*| ENABLE_GEOLOCATION 0|" \
    -e "s| ENABLE_ORIENTATION_EVENTS .*| ENABLE_ORIENTATION_EVENTS 0|" \
    -e "s| ENABLE_REMOTE_INSPECTOR .*| ENABLE_REMOTE_INSPECTOR 0|" \
    -i Source/WTF/wtf/FeatureDefines.h

  #-DUSE_SYSTEM_MALLOC=ON
  #printf %s\\n "#define ENABLE_JIT 0 >> Source/WTF/wtf/FeatureDefines.h

  sed -i '39 a\
    #include <cmath>' Source/JavaScriptCore/runtime/Options.cpp

  make -j "$(nproc)" -C Source/bmalloc/bmalloc || die "Source/bmalloc/bmalloc build... Failed"
  make -j "$(nproc)" -C Source/WTF/wtf || die "Source/WTF/wtf build... Failed"
  make -j "$(nproc)" -C Source/JavaScriptCore gen || die "Source/JavaScriptCore gen build... Failed"
  make -j "$(nproc)" -C Source/JavaScriptCore || die "Source/JavaScriptCore build... Failed"
  make -j "$(nproc)" -C Source/WebCore || die "Source/WebCore build... Failed"
  make -j "$(nproc)" -C Source/WebKit/fltk || die "Source/WebKit/fltk build... Failed"

  . runverb \
  make -C Source/WebKit/fltk DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  #mv -vn "usr/$(get_libdir)" .
  #sed -i "4s|^libdir=.*|libdir=/$(get_libdir)|;t" $(get_libdir)/pkgconfig/"vpx.pc"

  #use 'shared' && chmod +x "$(get_libdir)/"lib${PN}.so.${SYMVER}
  #use 'static-libs' && chmod +x "$(get_libdir)/"lib*.la

  #use 'doc' || rm -vr -- "usr/share/doc/" "usr/share/man/"

  #use 'static-libs' || { find "$(get_libdir)/" -name '*.la' -delete || die;}

  #if use 'strip'; then
  #  /bin/strip --verbose --strip-all "sbin/"* "$(get_libdir)/"lib${PN}.so
  #fi
  #strip --strip-unneeded "$(get_libdir)/"lib${PN}.a
  #if use !strip; then
  #  :
  #elif use 'strip' && use 'static-libs'; then
  #  strip --strip-unneeded "$(get_libdir)/"lib${PN}*.a "$(get_libdir)/"lib${PN}*.a.*
  #elif use 'strip' && use 'shared'; then
  #  strip --verbose --strip-all "$(get_libdir)/"lib${PN}*.so "$(get_libdir)/"lib${PN}*.so.*
  #fi

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${XPV} pkg-create-cgz