#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-16 02:00 UTC - last change
# Build with useflag: +static +static-libs -shared +ipv6 -nls -ftp +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="8.3.4"
DESCRIPTION="The PHP language runtime engine"
HOMEPAGE="https://www.php.net/"
SRC_URI="
  https://www.php.net/distributions/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/dev-lang/php/files/php-iodbc-header-location.patch
"
LICENSE="PHP-3.01 BSD Zend-2.0 BSD-2 LGPL-2.1 LGPL-2.1+"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs -shared (+musl) -pcre2 -crypt +ipv6 -debug -test +strip"
IUSE="${IUSE} -nls -rpath -man -doc +embed -cli +cgi -fpm -apache2 -phpdbg -threads -acl"
IUSE="${IUSE} -apparmor -argon2 -avif +bcmath -bzip2 +calendar -capstone -cjk"
IUSE="${IUSE} +dba +cdb -berkdb +flatfile -gdbm +inifile -qdbm -tokyocabinet -lmdb"
IUSE="${IUSE} -pdo -mssql -mysql -postgres -sqlite -firebird -oci8-instant-client"
IUSE="${IUSE} +ctype -curl -debug -enchant -exif -ffi +fileinfo +filter"
IUSE="${IUSE} -ftp -gd -gmp -iconv -imap -intl -iodbc -jit -kerberos -ldap -ldap-sasl"
IUSE="${IUSE} -libedit -mhash -mysqli -odbc -opcache -pcntl +phar +posix -readline"
IUSE="${IUSE} -selinux +session -session-mm -sharedmem -snmp -soap -sockets"
IUSE="${IUSE} -sodium -spell -ssl -sysvipc -systemd -tidy +tokenizer -truetype +unicode"
IUSE="${IUSE} -valgrind -webp -xml -simplexml -xmlreader -xmlwriter -xpm -xslt -zip +zlib"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
CATEGORY=${11:-$CATEGORY}
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
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
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
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'pcre2' || pkginst "dev-libs/pcre2"
use 'static' || pkginst "dev-libs/pcre"
use 'xml' && pkginst "dev-libs/libxml2"
use 'sqlite' && pkginst "dev-db/sqlite"
use 'zlib' && pkginst "sys-libs/zlib"
use 'gd' && pkginst "media-libs/libjpeg-turbo" "media-libs/libpng"
use 'nls' && pkginst "sys-devel/gettext"

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

  patch -p1 -E < "${FILESDIR}/${PN}-iodbc-header-location.patch"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'static' && LD_LIBRARY_PATH=

	IFS=${NL}

  . runverb \
  ./configure \
    CC="gcc$(usex static ' -static --static')" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}/etc" \
    --with-config-file-path="/etc" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datadir="${DPREFIX}/share/${PN}" \
    --mandir="${DPREFIX}/share/man" \
    --localstatedir="/var" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-pear \
    --without-apxs2 \
    --disable-cli \
    --disable-fpm \
    --disable-phpdbg \
    $(use_enable 'cgi') \
    $(use_with 'iconv') \
    --disable-opcache \
    $(use_with 'zlib') \
    $(use_enable 'bcmath') \
    $(use_with 'bzip2' bz2) \
    $(use_enable 'calendar') \
    $(use_enable 'posix') \
    $(use_enable 'simplexml') \
    $(use_enable 'xml' dom) \
    $(use_with 'xml' libxml) \
    $(use_enable 'xml') \
    $(use_enable 'xmlreader') \
    $(use_enable 'xmlwriter') \
    $(usex 'dba' "--enable-dba=static" "--disable-dba") \
    $(use_enable 'flatfile') \
    $(use_with 'gdbm') \
    $(use_enable 'pdo') \
    $(use_with 'sqlite' sqlite3) \
    $(use_with 'sqlite' pdo-sqlite) \
    $(use_with 'gmp') \
    $(use_enable 'ftp') \
    $(use_enable 'unicode' mbstring) \
    --disable-mbregex \
    $(use_with !static external-pcre) \
    --without-pcre-jit \
    $(use_with 'readline') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_with 'nls' gettext) \
    $(use_enable 'rpath') \
    CFLAGS="${CFLAGS}" \
    LDFLAGS="$(usex static '-s -static --static ')${LDFLAGS}" \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make INSTALL_ROOT="${ED}" install || die "make install... error"

  mkdir -m 0755 "${ED}/etc/"
  mv -n php.ini-production "${ED}"/etc/php.ini

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "bin/php-config" "bin/phpize" "$(get_libdir)/" "usr/" || die

  use 'static' && LD_LIBRARY_PATH=
  bin/${PN}-cgi --version || die "binary work... error"

  ldd "bin/${PN}-cgi" || { use 'static' && true;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
