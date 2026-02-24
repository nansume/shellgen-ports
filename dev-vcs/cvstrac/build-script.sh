#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-03-15 20:00 UTC, 2026-02-24 01:00 UTC - last change
# Build with useflag: +static +vhosts -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://109897.bugs.gentoo.org/attachment.cgi?id=71058
# https://cgit.freebsd.org/ports/plain/devel/cvstrac/Makefile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH HTML_DOCS

DESCRIPTION="A web-based bug and patch-set tracking system for CVS."
HOMEPAGE="http://www.cvstrac.org/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="2.0.1"
PN2="sqlite"
SPN2="sqlite-version"
PV2="3.6.6.2"
SRC_URI="
  http://www.cvstrac.org/${PN}-${PV}.tar.gz
  https://github.com/sqlite/sqlite/archive/version-${PV2}.tar.gz -> ${PN2}-${PV2}.tar.gz
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="/usr/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+vhosts +static (+musl) -doc +stest +strip"
HTML_DOCS="howitworks.html"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
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
  "#app-text/rcs" \
  "#dev-util/cvs" \
  "dev-util/pkgconf" \
  "sys-apps/file  # for build sqlite3" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
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

  MY_HTDOCSDIR="/srv/www/htdocs"
  MY_CGIBINDIR="/srv/www/htdocs/cgi-bin"

  inherit install-functions eutils webapp

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz; do
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-cflags -ffunction-sections -fdata-sections
  append-ldflags -Wl,--gc-sections
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="cc"

  ########################### build: <dev-db/sqlite3> ################################

  cd "${WORKDIR}/${SPN2}-${PV2}/" || die "builddir: not found... error"

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN2}" install || die "make install... error"

  ############################## build: <main-package> ####################################

  append-ldflags -s -static --static

  #append-cflags -Dtime_t=__time32_t

  #CC="${CC} -static --static"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN2}/lib/pkgconfig"

  # ----------------------------------------------------------------------------------------

  mkdir -pm 0755 -- "${BUILD_DIR}/obj/"
  ln -s ${BUILD_DIR}/linux-gcc.mk ${BUILD_DIR}/obj/Makefile
  sed \
    -e "/BCC = / s|= .*|= ${CC} ${CFLAGS} ${LDFLAGS}|" \
    -e "/TCC = / s|= .*|= ${CC} ${CFLAGS} ${LDFLAGS}|" \
    -e "s#/home/drh/cvstrac/cvstrac#${BUILD_DIR}#" \
    -e "/^LIBSQLITE = / s|= .*|= -lcrypt -lm -L${BUILD_DIR}/${PN2}/$(get_libdir) -lsqlite3|" \
    -i ${BUILD_DIR}/obj/Makefile

  # FIX: add missing headers for musl libc.
  sed \
    -e 's|^#include <time.h>$||' \
    -e '/^#include "config.h"$/a #include <time.h>' \
    -i ${BUILD_DIR}/*.c

  sed -e '/^#include <unistd.h>$/a #include <time.h>' -i ${BUILD_DIR}/cgi.c
  sed -e '/^#include <stdlib.h>$/a #include <time.h>' -i ${BUILD_DIR}/throttle.c

  cd "${BUILD_DIR}/obj/" || die "builddir: not found... error"

  make -j "1" || die "Failed make build"

  mkdir -pm 0755 -- "${ED}"/bin/ "${ED}"/${MY_HTDOCSDIR}/ "${ED}"/${MY_CGIBINDIR}/
  mv -n ${PN} -t "${ED}"/bin/ || die "make install... error"

  cd "${BUILD_DIR}/"

  : webapp_src_preinst
  einstalldocs

  echo "#!/bin/sh" > ${ED}/${MY_CGIBINDIR}/cvstrac.cgi || die
  echo "cvstrac cgi /var/lib/cvstrac" >> ${ED}/${MY_CGIBINDIR}/cvstrac.cgi || die

  insinto ${MY_HTDOCSDIR}
  #doins *.gif obj/index.html
  doins obj/index.html

  chmod +x ${ED}/${MY_CGIBINDIR}/cvstrac.cgi

  keepdir /var/lib/cvstrac

  : webapp_serverowned ${MY_HTDOCSDIR}
  : webapp_src_install

  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "bin/${PN}"

  bin/${PN} --help || : die "binary work... error"
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz

pkg_postinst() {
  einfo "To initialize a new CVSTrac database, type the following command"
  einfo "(must be a user other than root to initialize):"
  einfo ""
  einfo "    cvstrac init /var/lib/cvstrac demo"
  einfo ""
  einfo "Open a browser and point to http://host/cvstrac.cgi/demo/"
  einfo "with user setup and password setup to continue."
  einfo ""
  einfo "Please visit the CVSTrac install guide for further details:"
  einfo "http://www.cvstrac.org/cvstrac/wiki?p=CvstracInstallation"
}
