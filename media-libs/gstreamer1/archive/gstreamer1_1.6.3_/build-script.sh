#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-15 16:00 UTC - last change
# Build with useflag: +static-libs +shared -doc -xstub +musl +stest +strip +x32

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH PYTHON

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${PN}
XPN="${6:-${XPN:?}}"
PV="1.6.3"
DESCRIPTION="Open source multimedia framework"
HOMEPAGE="https://gstreamer.freedesktop.org/"
SRC_URI="
  https://${PN}.freedesktop.org/src/${PN}/${PN}-${PV}.tar.xz
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}-${PV}/${PN}-${PV}-fix-strsignal.patch
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}-${PV}/${PN}-${PV}-musl2.patch
  http://shellgen.mooo.com/pub/distfiles/patch/${PN}-${PV}/${PN}-${PV}-musl3.patch
  #https://705974.bugs.gentoo.org/attachment.cgi?id=604218 -> gstreamer-1.14.5-make-fix.patch
"
LICENSE="LGPL-2+"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static-libs +shared (+musl) (-patch) (-debug) +stest -test +strip"
IUSE="${IUSE} -nls -rpath -doc +caps +introspection +orc -xstub"
IUSE="${IUSE} -introspection"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
PN="${PN:-${P%%_*}}"
PN=${12:-$PN}
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
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
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
PYTHON="true"

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
  "dev-lang/perl" \
  "dev-libs/libffi  # for glib" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc" \
  "sys-devel/m4  # for bison" \
  "sys-devel/make" \
  "sys-devel/patch" \
  "sys-kernel/linux-headers" \
  "dev-libs/glib-compat" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

pkginst \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/gettext" \
  "sys-devel/libtool" \
  || die "Failed install build pkg depend... error"

use 'caps'          && pkginst "sys-libs/libcap"
use 'introspection' && pkginst "dev-libs/gobject-introspection"
use 'nls'           && pkginst "sys-devel/gettext"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"
  { test -x "/bin/g${PATCH}" && test ! -L "/bin/g${PATCH}" ;} && PATCH="/bin/g${PATCH}"
  printf %s\\n "PATCH='${PATCH}'"

  ${PATCH} -p1 -E < "${FILESDIR}/${PN}-${PV}-fix-strsignal.patch"
  ${PATCH} -p1 -E < "${FILESDIR}/${PN}-1.14.5-make-fix.patch"
  case $(tc-chost) in
    *-"musl"*)
      ${PATCH} -p1 -E < "${FILESDIR}/${PN}-${PV}-musl2.patch"
      ${PATCH} -p1 -E < "${FILESDIR}/${PN}-${PV}-musl3.patch"
      #patch
    ;;
  esac

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O3
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  #append-cflags -std=gnu99

  #append-cppflags -I${WORKDIR}/win32/common/ -D__STRICT_ANSI__ -D_XOPEN_SOURCE

  CC="gcc"
  CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  autoreconf --install

	IFS=${NL}

  . runverb \
  ./configure \
    _CC=${CC} \
    _CXX=${CXX} \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}/etc" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/$(get_libdir)" \
    --datarootdir="${DPREFIX}/share" \
    --datadir="${DPREFIX}/share" \
    --infodir="${DPREFIX}/share/info" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-ptp-helper-permissions=$(usex 'caps' capabilities setuid-root) \
    $(usex !caps --with-ptp-helper-setuid-user=nobody) \
    $(usex !caps --with-ptp-helper-setuid-group=nobody) \
    --disable-debug \
    --disable-examples \
    --disable-valgrind \
    --enable-check \
    $(use_enable 'test' tests) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    --with-package-name="GStreamer ebuild for Shellgen" \
    --with-package-origin="ftp://shellgen.mooo.com/pkg/media-libs/gstreamer" \
    _CFLAGS="${CFLAGS}" \
    _CXXFLAGS="${CXXFLAGS}" \
    $(test -n "${LDFLAGS}" && printf %s "_LDFLAGS=${LDFLAGS}") \
    || die "configure... error"

  make -j "$(nproc --ignore=3)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  #mkdir -pm 0755 "${ED}/bin/"
  #cp -lp tcpsvd udpsvd ipsvd-cdb "${ED}/bin/"
  #mv -vn "${PN}-static" "${ED}/bin/${PN}"
  #printf %s\\n "Install... ok"

  cd "${ED}/" || die "install dir: not found... error"

  #post-inst-perm
  #use 'shared' && chmod +x "$(get_libdir)/"lib${PN}.so.${SYMVER}
  #use 'static' && chmod +x "$(get_libdir)/"lib*.la

  #RMLIST=$(pkg-rmlist) pkg-rm
  use 'doc' || rm -vr -- "usr/share/doc/" "usr/share/man/"
  #rmdir var/run/ || die

  #post-rm
  #use 'static-libs' || find "$(get_libdir)/" -name '*.la' -delete || die
  #pkg-rm-empty

  #use strip && pkg-strip
  #if use 'strip'; then
  #  /bin/strip --verbose --strip-all "sbin/"* "$(get_libdir)/"lib${PN}.so
  #fi
  #strip --strip-unneeded "$(get_libdir)/"lib${PN}.a

  #use 'static' && LD_LIBRARY_PATH=
  #use 'stest' && { bin/${PN} --version -version -V -v -h --help || die "binary work... error";}

  #ldd "bin/${PN}" || { use 'static' && true;}

  #pre-perm
  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
