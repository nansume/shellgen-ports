#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-10 13:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# <orig-url-build-script>

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="<pkgdesc>"
HOMEPAGE="<url>"
LICENSE="<license>"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="1.3.2"
#PV="1.3.3"  # BUG: static build nowork - binary is shared
#PV="1.3.7"  # BUG: network fetch (HDRS = ... utfdata.h)
#PV="1.3.8"  # TODO: bump pkg version
PN2="readline"
PV2="8.1.2"
SRC_URI="
  https://mujs.com/downloads/${PN}-${PV}.tar.xz
  #https://mujs.com/downloads/${PN}-${PV}.tar.gz  # >= 1.3.3
  http://ftp.gnu.org/gnu/readline/${PN2}-${PV2}.tar.gz
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-5.0-no_rpath.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-7.0-headers.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-8.0-headers.patch
  http://data.gpo.zugaina.org/gentoo/sys-libs/readline/files/readline-8.1-windows-signals.patch
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
ZCOMP="gunzip"
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
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
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/netbsd-curses" \
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

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in
      '*'.tar.*)  continue       ;;
       *.tar.gz)  ZCOMP="gunzip" ;;
       *.tar.xz)  ZCOMP="unxz"   ;;
    esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && { use 'static-libs' || use 'static' ;}; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  ########################### build: <sys-libs/readline> ################################

  use 'static' && {

  cd "${WORKDIR}/${PN2}-${PV2}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/${PN2}-5.0-no_rpath.patch
  patch -p1 -E < "${FILESDIR}"/${PN2}-7.0-headers.patch
  patch -p1 -E < "${FILESDIR}"/${PN2}-8.0-headers.patch
  patch -p1 -E < "${FILESDIR}"/${PN2}-8.1-windows-signals.patch

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-curses \
    --disable-shared \
    --enable-static \
    --disable-install-examples \
    || die "configure... error"

  make -j1 || die "Failed make build"

  make DESTDIR="${BUILD_DIR}/${PN2}" install-static || die "make install... error"
  }

  ############################## build: <main-package> ####################################

  CC="${CC} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  READLINE_LIBS="-L${BUILD_DIR}/${PN2}/$(get_libdir) -lreadline -lhistory"
  READLINE_LIBS="-L${BUILD_DIR}/${PN2}/$(get_libdir) -lreadline"

  use 'static' && append-ldflags "-s -static --static"

  INSTALL_OPTS=
  use 'shared' && INSTALL_OPTS="${INSTALL_DIR:+${INSTALL_DIR} }install-shared"
  use 'static-libs' && INSTALL_OPTS="${INSTALL_DIR:+${INSTALL_DIR} }install-static"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed \
    -e "/LIBREADLINE +=/ s| -lreadline$| ${READLINE_LIBS} -lterminfo|" \
    -e "/READLINE_LIBS =/ s| -lreadline$| ${READLINE_LIBS} -lterminfo|" \
    -e "/\t$(CC) / s| -lreadline$| ${READLINE_LIBS} -lterminfo|" \
    -i Makefile

  make -j "$(nproc)" \
    DESTDIR="${ED}" \
    prefix="${EPREFIX%/}" \
    bindir="${EPREFIX%/}/bin" \
    libdir="${EPREFIX%/}/$(get_libdir)" \
    incdir="${EPREFIX%/}/${INCDIR#/}" \
    $(usex 'static-libs' static shared) \
    ${INSTALL_OPTS} \
    || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && pkg-strip

  use 'stest' && { bin/${PROG} -h || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz