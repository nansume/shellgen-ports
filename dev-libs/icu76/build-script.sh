#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-23 19:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-libs/icu/icu-76.1-r1.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="International Components for Unicode"
HOMEPAGE="http://www.icu-project.org/"
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
PN=${PN%[0-9][0-9]}
PV="76.1"
XPV=${PV/./-}  # no-posix
SRC_URI="
  http://ftp2.osuosl.org/pub/blfs/conglomeration/icu/icu4c-${PV/./_}-src.tgz
  http://data.gpo.zugaina.org/gentoo/dev-libs/icu/files/icu-76.1-remove-bashisms.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/icu/files/icu-68.1-nonunicode.patch
  http://data.gpo.zugaina.org/gentoo/dev-libs/icu/files/icu-76.1-undo-pkgconfig-change-for-now.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+extras -debug -test -nls -rpath -examples -doc -xstub"
IUSE="${IUSE} +static-libs +shared (+musl) (-patch) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/icu/source"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="uconv"

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
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
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

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  gpatch -p1 -E < "${FILESDIR}/${PN}-76.1-remove-bashisms.patch"
  gpatch -p1 -E < "${FILESDIR}/${PN}-68.1-nonunicode.patch"

  # Undo change for now which exposes underlinking in consumers;
  # revisit when things are a bit quieter and tinderbox its removal.
  gpatch -p1 -E < "${FILESDIR}/${PN}-76.1-undo-pkgconfig-change-for-now.patch"

  # Disable renaming as it is stupid thing to do
  sed \
   -e "s/#define U_DISABLE_RENAMING 0/#define U_DISABLE_RENAMING 1/" \
   -i common/unicode/uconfig.h || die

  # ODR violations, experimental API
  sed \
   -e "s/#   define UCONFIG_NO_MF2 0/#define UCONFIG_NO_MF2 1/" \
   -i common/unicode/uconfig.h || die

  # Fix linking of icudata
  sed \
   -e "s:LDFLAGSICUDT=-nodefaultlibs -nostdlib:LDFLAGSICUDT=:" \
   -i config/mh-linux || die

  # Append doxygen configuration to configure
  sed \
   -e 's:icudefs.mk:icudefs.mk Doxyfile:' \
   -i configure.ac || die

  . runverb \
  ./configure \
    CC=${CC} \
    CXX=${CXX} \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-renaming \
    --disable-samples \
    --disable-layoutex \
    --disable-debug \
    $(usex !extras --disable-extras) \
    --disable-tests \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'rpath') \
    CFLAGS="${CFLAGS}" \
    $(test -n "${LDFLAGS}" && printf %s "LDFLAGS=${LDFLAGS}") \
    || die "configure... error"

  make -j "$(nproc --ignore=2)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  if use 'strip'; then
    use 'shared' && strip --verbose --strip-all "bin/"* "sbin/"* "$(get_libdir)/"lib${PN}*.so.${PV}
    use 'static-libs' && {
      strip --strip-unneeded "$(get_libdir)/"lib${PN}*.a
      chmod -x "$(get_libdir)/"lib${PN}*.a
    }
  fi

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'stest' && { bin/${PROG} --version || die "binary work... error";}

  ldd "bin/${PROG}" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz