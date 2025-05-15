#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-16 14:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-vpn/i2pd/i2pd-2.55.0.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="A C++ daemon for accessing the I2P anonymous network"
HOMEPAGE="https://github.com/PurpleI2P/i2pd"
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
PN=${PN%[0-9]}
PV="2.43.0"
PV="2.56.0"
#PN2="libevent"
#PV2="2.1.12"
SRC_URI="
  https://github.com/PurpleI2P/i2pd/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  #ftp://ftp.vectranet.pl/gentoo/distfiles/i2pd-2.43.0.tar.gz
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-cpu_flags_x86_aes -aesni -upnp +static -static-libs -shared (+musl) -debug -doc +stest +strip"
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
  "dev-libs/cxx-boost" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl0" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

if use 'static'; then
  pkginst "dev-libs/openssl"
else
  pkginst "dev-libs/openssl3"
fi

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
    case ${PF} in '*'.tar.*) continue;; *.tar.gz) ZCOMP="gunzip";; *.tar.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"

  #############################################################################

  use 'zzzz' && {
  cd "${WORKDIR}/${PN2}-${PV2}-stable/" || die "builddir: not found... error"


  LDFLAGS="${LDFLAGS}${LDFLAGS:+ }-Wl,--gc-sections" \
  CFLAGS="${CFLAGS/-O2/-Os} -ffunction-sections -fdata-sections" \
  CXXFLAGS=${CXXFLAGS/-O?/-Os} \
  FFLAGS=${FFLAGS/-O?/-Os} \
  FCFLAGS=${FCFLAGS/-O?/-Os} \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-openssl \
    --enable-static \
    --disable-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN2}" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN2}/$(get_libdir) -levent"
  PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:${BUILD_DIR}/${PN2}/$(get_libdir)/pkgconfig"
  }

  #############################################################################

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  CXXFLAGS="${CXXFLAGS}$(usex static ' -DUSE_STATIC')$(usex aesni ' -DUSE_AESNI')"
  CXXFLAGS="${CXXFLAGS}$(usex hardening ' -DUSE_HARDENING')$(usex shared ' -DUSE_LIBRARY')"
  CXXFLAGS="${CXXFLAGS} -DUSE_BINARY$(usex upnp ' -DUSE_UPNP')$(usex debug ' -DDEBUG')"

  make -j "$(nproc)" CXXFLAGS="${CXXFLAGS}" || die "Failed make build"

  use 'strip' && make strip

  #########################  Install  #########################
  mkdir -pm '0755' -- ${ED}/bin/ ${ED}/etc/i2pd/tunnels.conf.d/
  mkdir -pm '0755' -- ${ED}/usr/share/${PN}/
  mkdir -pm '0755' -- ${ED}/var/lib/${PN}/

  cp -v -nl ${PN} -t "${ED}"/bin/

  cp -v -nl contrib/i2pd.conf contrib/subscriptions.txt contrib/tunnels.conf -t ${ED}/etc/${PN}/

  use 'doc' && {
    mkdir -pm '0755' -- ${ED}/usr/share/doc/${PN}/ ${ED}/usr/share/man/man1/
    cp -v -nl ChangeLog LICENSE README.md contrib/${PN}.conf -t ${ED}/usr/share/doc/${PN}/
    cp -v -nl contrib/subscriptions.txt contrib/tunnels.conf -t ${ED}/usr/share/doc/${PN}/
    gzip -kf debian/${PN}.1 && mv -n debian/${PN}.1.gz -t ${ED}/usr/share/man/man1/
  }

  #cp -v -ulr contrib/certificates/ -t ${ED}/var/lib/${PN}/
  cp -R -nl contrib/certificates -t ${ED}/usr/share/${PN}/

  ln -sf /usr/share/${PN}/certificates ${ED}/var/lib/${PN}/
  ln -sf /etc/${PN}/tunnels.conf.d ${ED}/var/lib/${PN}/tunnels.d
  ln -sf /etc/${PN}/${PN}.conf ${ED}/var/lib/${PN}/
  ln -sf /etc/${PN}/subscriptions.txt ${ED}/var/lib/${PN}/
  ln -sf /etc/${PN}/tunnels.conf ${ED}/var/lib/${PN}/
  #############################################################

  cd "${ED}/" || die "install dir: not found... error"

  bin/${PN} --version || die "binary work... error"

  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
