#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2023, 2024-08-02 21:00 UTC, 2025-06-07 14:00 UTC - last change
# Build with useflag: +static -shared +nopie +patch -doc +mbedtls +openssl +diet -musl +stest +strip +amd64

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gatling
# https://at.magma-soft.at/sw/blog/posts/SSL_and_dietlibc_March_2018/

# BUG: x32 no-support, until make symlink `amd64` => `x32` how pseudo-fix (only static).
# BUG: with dietlibc no support ipv4, only ipv6, otherwise reuseaddr ipv6 error.
# BUG: `FTP PORT command failed` - no work in runtime.
# BUG: `.htaccess http auth it all false` - no work in runtime.
# TIP: openssl and mbedtls work, but uses nowadays cert`s no possible! (e.g: letsencrypt)

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export DIETHOME DIET CC

DESCRIPTION="High performance web server"
HOMEPAGE="http://www.fefe.de/gatling/"
LICENSE="GPL-2"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}; PN=${PN%-diet}
PV="0.16"      # gatling (is development version 0.17)
PV1="0.35"     # dietlibc
PV2="0.33"     # owfat
PV3="1.2.11"   # zlib
PN4="mbedtls"
PV4="2.7.19"   # mbedtls
PV5="1.1.0g"   # openssl
SRC_URI="
  http://www.fefe.de/${PN}/${PN}-${PV}.tar.xz
  http://www.fefe.de/dietlibc/dietlibc-${PV1}.tar.xz
  http://www.fefe.de/libowfat/libowfat-${PV2}.tar.xz
  https://zlib.net/zlib-${PV3}.tar.xz
  #https://github.com/Mbed-TLS/mbedtls/archive/v${PV4}.tar.gz -> ${PN4}-${PV4}.tar.gz
  #https://github.com/openssl/openssl/releases/download/OpenSSL_${PV5//./_}/openssl-${PV5}.tar.gz
  http://localhost/pub/distfiles/patch/01-gatling-openssl.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="(+asm) (+mbedtls) -openssl (+ssl) -webdav +ftp +zlib +static -shared -doc +diet +stest +strip"
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
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
MKTARGET="${PN} cgi"
DIETHOME="/opt/diet"

if test "X${USER}" != 'Xroot'; then
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

. "${PDIR%/}/etools.d/"build-functions

# FIX: no build with x32abi
use 'x32' && {
  USE="${USE} -x32 +amd64"
  ABI_BUILD="amd64"
  # (optional) TODO: remove it.
  ABI="${ABI_BUILD}"
  XABI="${ABI_BUILD}"
  LIB_DIR="lib64"
  LIBDIR="/${LIB_DIR}"
}

chroot-build || die "Failed chroot... error"

pkginst \
  "dev-lang/perl  # for openssl (needed: musl [shared-libs])" \
  "#dev-libs/dietlibc1  # FIX: for new ver dietlibc-0.35" \
  "#net-libs/mbedtls-diet" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9  # TODO: replace to: gcc14" \
  "sys-devel/make" \
  "#sys-kernel/linux-headers-musl  # for openssl" \
  "sys-libs/musl  # required for: dietlibc-0.35" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  mkdir -pm 0755 -- "${DIETHOME}/"
  chown ${BUILD_USER}:${BUILD_USER} -R "${DIETHOME}/"
  if use 'x86'; then
    ln -s gcc bin/i386-linux-gcc
    ln -s ar bin/i386-linux-ar
  elif use 'amd64' || use 'x32'; then
    ln -s gcc bin/$(arch)-linux-gcc
    ln -s ar bin/$(arch)-linux-ar
  fi
  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.xz *.tar.gz; do
    case ${PF} in *.tar.gz) ZCOMP="gunzip";; '*'*) continue;; esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -fno-stack-protector ;;
    'x86')   append-flags -m32                       ;;
    'amd64') append-flags -m64  -fno-stack-protector ;;
  esac
  append-ldflags -Wl,--gc-sections
  #append-ldflags "-s -static --static"
  append-cflags -ffunction-sections -fdata-sections
  append-flags -Os -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  #PATH="${PATH:+${PATH}:}${DIETHOME}/bin"
  #LDFLAGS="${LDFLAGS} -s -L${DIETHOME}/lib-$(arch) -lc"
  #CFLAGS="${CFLAGS} -I${DIETHOME}/include"
  #DIET="diet"

  use 'openssl' && USE="${USE} -mbedtls"

	#########################################################################################

  cd "${WORKDIR}/dietlibc-${PV1}/" || die "builddir: not found... error"

  # Makefile does not append CFLAGS
  DIETOPTS="-W -Wall -Wchar-subscripts"
  DIETOPTS="${DIETOPTS} -Wmissing-prototypes -Wmissing-declarations -Wno-switch"
  DIETOPTS="${DIETOPTS} -Wno-unused -Wredundant-decls -fno-strict-aliasing"
  DIETOPTS="${DIETOPTS} -Wa,--noexecstack"

  sed -e 's:strip::' -i Makefile || die

  use 'x32' && ln -s bin-x32 bin-$(tc-arch)
  mkdir -pm 0755 -- "${WORKDIR}/dietlibc-${PV1}/bin/"
  if use 'x86'; then
    ln -s /bin/${CC} ${WORKDIR}/dietlibc-${PV1}/bin/i386-linux-${CC}
    ln -s /bin/ar ${WORKDIR}/dietlibc-${PV1}/bin/i386-linux-ar
  elif use 'amd64'; then
    ln -s /bin/${CC} ${WORKDIR}/dietlibc-${PV1}/bin/$(arch)-linux-${CC}
    ln -s /bin/ar ${WORKDIR}/dietlibc-${PV1}/bin/$(arch)-linux-ar
    ln -s ${DIETHOME}/lib-$(arch) ${WORKDIR}/dietlibc-${PV1}/lib-$(arch)
    ln -s diet ${DIETHOME}/bin/$(arch)-linux-diet
  fi
  PATH="${PATH:+${PATH}:}${WORKDIR}/dietlibc-${PV1}/bin"
  #CC="diet -Os gcc -nostdinc"

  # CC="${CC} -D__dietlibc__ -I. -I${DIETHOME}/include -isystem include" \  # diet

  make -j1 \
    CC="${CC} -D__dietlibc__ -I. -isystem include" \
    CFLAGS="${CFLAGS} -no-pie ${DIETOPTS}" \
    prefix="${DIETHOME}" \
    BINDIR="${DIETHOME}/bin" \
    MAN1DIR="${DIETHOME}/usr/share/man/man1" \
    DESTDIR="" \
    STRIP=":" \
    $(use 'x32' && printf "x32") \
    $(use 'x86' && printf "i386") \
    $(use 'amd64' && printf "$(arch)") \
    install-bin install-headers || die "make build... error"

  cd "${DIETHOME}/" || die "install dir: not found... error"

  use 'x32' && ln -sf "lib-$(arch)" "lib-$(tc-abi)"

  #strip --verbose --strip-all "bin/"*
  #strip --strip-unneeded  "lib-"*"/"*

  PATH="${PATH:+${PATH}:}${DIETHOME}/bin"
  LDFLAGS="${LDFLAGS} -s -L${DIETHOME}/lib-$(arch) -lc"
  CFLAGS="${CFLAGS} -I${DIETHOME}/include"
  DIET="diet" CC="diet -Os gcc -nostdinc"

  #########################################################################################

  use 'zlib' && {
	cd "${WORKDIR}/zlib-${PV3}/" || die "builddir: not found... error"

  CFLAGS="${CFLAGS} -no-pie" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/zlib" install || die "make install... error"

  #strip --strip-unneeded "${BUILD_DIR}/zlib/$(get_libdir)/"*.a

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/zlib/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/zlib/$(get_libdir) -lz"
  }

  ###################### build: <net-libs/mbedtls> (optional) #############################

  use 'mbedtls' && {
  cd "${WORKDIR}/${PN4}-${PV4}/" || die "builddir: not found... error"

  make -j "$(nproc)" MBEDTLS_TEST_OBJS="" lib || die "Failed make build or install... error"

  mkdir -pm 0755 "${BUILD_DIR}/${PN4}/usr/include/"
  mv -n include/${PN4} -t "${BUILD_DIR}/${PN4}/usr/include/"
  mkdir -pm 0755 "${BUILD_DIR}/${PN4}/$(get_libdir)"
  mv -n library/libmbed*.a -t "${BUILD_DIR}/${PN4}/$(get_libdir)/"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/${PN4}/usr/include"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/${PN4}/$(get_libdir) -lmbedx509 -lmbedcrypto"

  MKTARGET="${MKTARGET} ptls${PN}"
  }

  ###################### build: <dev-libs/openssl3> (optional) ############################

  use 'openssl' && {
  cd "${WORKDIR}/openssl-${PV5}/" || die "builddir: not found... error"

  #CFLAGS="${CFLAGS} -no-pie" \
  #LDFLAGS="${LDFLAGS}" \
  CC="${CC} -I/usr/include ${CFLAGS} -no-pie ${LDFLAGS}" \
  ./config \
    --prefix="${DPREFIX%/}" \
    --libdir="/$(get_libdir)" \
    $(usex 'x86' 386) \
    $(usex 'sse2' enable-sse2 no-sse2) \
    no-camellia \
    enable-ec no-ec2m no-gost enable-ecdsa enable-ecdh \
    no-srp \
    no-idea \
    no-mdc2 \
    no-rc5 \
    no-rfc3779 \
    no-sctp \
    no-weak-ssl-ciphers \
    zlib \
    $(usex 'diet' no-async) \
    $(usex 'asm' enable-asm no-asm) \
    no-pic \
    threads \
    no-dso \
    no-shared \
    no-engine \
    -lpthread \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${BUILD_DIR}/openssl" INSTALLTOP=${DPREFIX} OPENSSLDIR="/etc/ssl" install_sw \
  || die "make install... error"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/openssl/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/openssl/usr/lib -lcrypto -lssl"
  #PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:${BUILD_DIR}/openssl/usr/lib/pkgconfig"

  MKTARGET="${MKTARGET} tls${PN}"
  }

  #########################################################################################

  cd "${WORKDIR}/libowfat-${PV2}/" || die "builddir: not found... error"

  append-flags -fomit-frame-pointer

  make headers

  make -j "$(nproc)" \
    DIET="" \
    CC="${CC}" \
    CFLAGS="-I${DIETHOME}/include -I. ${CFLAGS} -no-pie" \
    DESTDIR="${BUILD_DIR}/libowfat" \
    prefix="${EPREFIX%/}" \
    LIBDIR="${EPREFIX%/}/$(get_libdir)" \
    INCLUDEDIR="${INCDIR}" \
    MAN3DIR="${DPREFIX}/share/man/man3" \
    all install \
    || die "Failed make build"

  #strip --strip-unneeded "${BUILD_DIR}/libowfat/$(get_libdir)/libowfat.a"

  CFLAGS="${CFLAGS} -I${BUILD_DIR}/libowfat/${INCDIR#/}/libowfat"
  CFLAGS="${CFLAGS} -I${BUILD_DIR}/libowfat/${INCDIR#/}"
  LDFLAGS="${LDFLAGS} -L${BUILD_DIR}/libowfat/$(get_libdir) -lowfat"

  #########################################################################################

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  use 'openssl' && patch -p1 -E < "${FILESDIR}"/01-gatling-openssl.patch

	sed -e "/^MANDIR=/d" -e "/^CFLAGS=/d" -e "/^LDFLAGS=/d" -i Makefile GNUmakefile
	sed -e '/^[[:space:]]install -d / s| $(man1dir)| $(DESTDIR)$(man1dir)|' -i Makefile GNUmakefile

  # TODO: uncomment and testing
	#sed -e 's|/usr/local/include|/usr/include/libowfat|' -i GNUmakefile

	sed \
	  -e 's|^\(#define SUPPORT_SERVERSTATUS\)$|// \1|' \
	  -e 's|^// \(_#define SUPPORT_DAV\)$|\1|' \
	  -e 's|^\(#define SUPPORT_SMB\)$|// \1|' \
	  -e 's|^\(_#define SUPPORT_FTP\)$|// \1|' \
	  -e 's|^\(#define SUPPORT_BROTLI\)$|// \1|' \
	  -i gatling_features.h

  append-cflags -Wno-implicit-function-declaration

	rm -- Makefile

	# SMB_SUPPORT="0" \
	# $(usex !ftp FTP_SUPPORT=0) \
	# SUPPORT_DAV="$(usex webdav 1 0)" \

  make -j1 \
    DIET="${DIET}" \
    CC="${CC}" \
    CFLAGS="${CFLAGS} -no-pie" \
    LDFLAGS="${LDFLAGS} -lpthread" \
    DESTDIR="${ED}" \
    prefix="${EPREFIX%/}" \
    MANDIR="${DPREFIX}/share/man" \
    $(usex !zlib ZLIB="0") \
    ${MKTARGET} install \
    || printf %s\\n "die 'Failed make build'"

  use 'mbedtls' && mv -n ptls${PN} -t "${ED}"/bin/
  test -x "cgi" && mv -n cgi -t "${ED}"/bin/

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -v -r -- "usr/share/man/" "usr/"

  strip --verbose --strip-all "bin/"*

  use 'stest' && { bin/${PN} -h || : die "binary work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz