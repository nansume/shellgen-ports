#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-12-25 23:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# openwrt/packages-master/net/uacme/Makefile

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH LIBS

DESCRIPTION="lightweight client for ACMEv2"
HOMEPAGE="https://github.com/ndilieto/uacme"
LICENSE="GPL-3.0-or-later"
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
PV="1.7.4"
PN2="curl"
PV2="8.9.1"
SRC_URI="
  https://codeload.github.com/ndilieto/uacme/tar.gz/upstream/${PV} -> /${PN}-${PV}.tar.gz
  https://curl.se/download/${PN2}-${PV2}.tar.xz
  http://data.gpo.zugaina.org/gentoo/net-misc/curl/files/curl-respect-cflags-3.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
inst="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+mbedtls +static -shared -doc (+musl) +stest +strip"
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
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-upstream-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
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
  "app-misc/ca-certificates  # deps curl" \
  "dev-libs/libev" \
  "dev-util/pkgconf" \
  "net-libs/mbedtls3" \
  "sys-devel/binutils9" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  ln -s mbedtls3/mbedtls /usr/include/mbedtls
  ln -s mbedtls3/psa /usr/include/psa
fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in '*'*) continue;; *.tar.gz) ZCOMP="gunzip";; *.tar.xz) ZCOMP="unxz";; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && inst="install-strip"

  ########################### build: <net-misc/curl[mbedtls]> ################################

  use 'static' && {

  cd "${WORKDIR}/${PN2}-${PV2}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/${PN2}-respect-cflags-3.patch

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-optimize \
    --disable-docs \
    --disable-mqtt \
    --with-ca-bundle="${EPREFIX%/}"/etc/ssl/certs/ca-certificates.crt \
    --without-gnutls \
    --with-mbedtls \
    --without-openssl \
    --with-default-ssl-backend="mbedtls" \
    --with-ssl \
    --disable-alt-svc \
    --enable-basic-auth \
    --enable-bearer-auth \
    --enable-digest-auth \
    --disable-kerberos-auth \
    --enable-negotiate-auth \
    --disable-aws \
    --disable-dict \
    --disable-ech \
    --disable-file \
    --disable-ftp \
    --disable-gopher \
    --disable-hsts \
    --enable-http \
    --disable-imap \
    --disable-ldap \
    --disable-ldaps \
    --disable-ntlm \
    --disable-pop3 \
    --disable-rt \
    --disable-rtsp \
    --disable-smb \
    --without-libssh2 \
    --disable-smtp \
    --disable-telnet \
    --disable-tftp \
    --disable-tls-srp \
    --enable-cookies \
    --enable-dateparse \
    --disable-dnsshuffle \
    --disable-doh \
    --enable-symbol-hiding \
    --enable-http-auth \
    --enable-ipv6 \
    --enable-largefile \
    --disable-manual \
    --enable-mime \
    --disable-netrc \
    --disable-progress-meter \
    --disable-proxy \
    --disable-socketpair \
    --disable-sspi \
    --disable-pthreads \
    --disable-threaded-resolver \
    --disable-versioned-symbols \
    --without-amissl \
    --without-bearssl \
    --without-brotli \
    --without-nghttp2 \
    --without-hyper \
    --without-libidn2 \
    --without-libgsasl \
    --without-libpsl \
    --without-msh3 \
    --without-nghttp3 \
    --without-ngtcp2 \
    --without-quiche \
    --without-librtmp \
    --without-schannel \
    --without-secure-transport \
    --without-test-caddy \
    --without-test-httpd \
    --without-test-nghttpx \
    --disable-websockets \
    --without-winidn \
    --without-wolfssl \
    --without-zlib \
    --without-zstd \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" DESTDIR="${BUILD_DIR}/${PN2}" install || die "Failed make build"

  sed \
    -e "/^prefix=/ s|=.*$|=${BUILD_DIR}/${PN2}/usr|" \
    -e "/^libdir=/ s|=.*$|=${BUILD_DIR}/${PN2}/$(get_libdir)|" \
    -e "/^includedir=/ s|=.*/include|=${BUILD_DIR}/${PN2}/usr/include|" \
    -e "/^Libs:/ s| -L/$(get_libdir) | -L${BUILD_DIR}/${PN2}/$(get_libdir) |" \
    -i ${BUILD_DIR}/${PN2}/$(get_libdir)/pkgconfig/*.pc
  }

  ############################## build: <main-package> ####################################

  append-ldflags "-s -static --static"
  LIBS="${LIBS}${LIBS:+ }-L/$(get_libdir) -lmbedtls -lmbedcrypto -lmbedx509"

  CC="${CC} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN2}/lib/pkgconfig"
  LIBS="${LIBS}${LIBS:+ }-L${BUILD_DIR}/${PN2}/$(get_libdir) -lcurl -lev"

  # ------------------------------------------------------------------------------------------

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --datadir="${EPREFIX%/}"/usr/share \
    --disable-maintainer-mode \
    --disable-docs \
    $(usex 'static' --with-libcurl="${BUILD_DIR}/${PN2}/$(get_libdir)") \
    --without-gnutls \
    --with-mbedtls \
    --without-openssl \
    --enable-splice \
    --without-ualpn \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${inst} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'stest' && { bin/${PROG} --version || : die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz