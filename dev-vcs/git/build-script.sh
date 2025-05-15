#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-02-22 01:00 UTC - last change
# Build with useflag: +static +blksha1 +ipv6 -perl +x32

export USER XPN PF PV WORKDIR BUILD_DIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC AR PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Stupid content tracker: distributed VCS designed for speed and efficiency"
HOMEPAGE="https://www.git-scm.com/"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="2.15.1"
PV="2.45.2"
SRC_URI="
  https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.45.2.tar.xz
  #ftp://ftp.vectranet.pl/gentoo/distfiles/${PN}-2.15.1.tar.xz
  http://data.gpo.zugaina.org/gentoo/dev-vcs/git/files/git-2.37.0_rc1-optional-cvs.patch
  http://data.gpo.zugaina.org/gentoo/dev-vcs/git/files/git-2.21.0-quiet-submodules-testcase.patch
"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static (+musl) -hardlink +ipv6 -iconv -nls +pcre +perl -debug (-test) +strip"
IUSE="${IUSE} +blksha1 +curl -cgi -doc -keyring +gpg -highlight -mediawiki -selinux -webgit"
IUSE="${IUSE} -perforce +safe-directory -subversion -tk -webdav +xinetd -cvs +ssl +openssl"
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
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
WORKDIR=${BUILD_DIR}
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
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
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"

use 'ssl'  && pkginst "dev-libs/openssl3"
use 'curl' && pkginst "net-misc/curl"
use 'pcre' && pkginst "dev-libs/pcre2"

use 'perl' &&
pkginst \
  "dev-lang/perl" \
  "dev-perl/error" \
  "dev-perl/mailtools" \
  "dev-perl/authen-sasl" \
  "dev-perl/perl-libnet  # perl-libnet[ssl]"

use 'gpg' &&
pkginst \
  "app-crypt/gnupg" \
  "dev-libs/libassuan" \
  "dev-libs/libgcrypt" \
  "dev-libs/libgpg-error" \
  "dev-libs/libksba" \
  "dev-libs/npth"

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

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Avoid automagic CVS, bug #350330
  /bin/gpatch -p1 -E < "${FILESDIR}"/git-2.37.0_rc1-optional-cvs.patch
  # Make submodule output quiet
  /bin/gpatch -p1 -E < "${FILESDIR}"/git-2.21.0-quiet-submodules-testcase.patch
  if ! use 'safe-directory'; then
    # This patch neuters the `safe directory` detection.
    # bugs #838271, #838223
    patch -p1 -E < "${FILESDIR}"/git-2.37.2-unsafe-directory.patch
  fi

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  # Can't define this to null, since the entire makefile depends on it
  sed -e '/\/usr\/local/ s/BASIC_/#BASIC_/' -i Makefile || die

  sed \
    -e 's:^\(CFLAGS[[:space:]]*=\).*$:\1 $(OPTCFLAGS) -Wall:' \
    -e 's:^\(LDFLAGS[[:space:]]*=\).*$:\1 $(OPTLDFLAGS):' \
    -e 's:^\(CC[[:space:]]* =\).*$:\1$(OPTCC):' \
    -e 's:^\(AR[[:space:]]* =\).*$:\1$(OPTAR):' \
    -e "s:\(PYTHON_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
    -e "s:\(PERL_PATH[[:space:]]\+=[[:space:]]\+\)\(.*\)$:\1${EPREFIX}\2:" \
    -i Makefile || die

  # Fix docbook2texi command
  sed -r 's/DOCBOOK2X_TEXI[[:space:]]*=[[:space:]]*docbook2x-texi/DOCBOOK2X_TEXI = docbook2texi.pl/' \
    -i Documentation/Makefile || die

  CC="gcc$(usex static ' -static --static')" AR="ar"
  export EXTLIBS="$(usex pcre -lpcre2-8)"

  . runverb \
  make -j "$(nproc)" \
    CC="${CC}" \
    CFLAGS="${CFLAGS}" \
    PKG_CONFIG="${PKG_CONFIG}" \
    GIT_TEST_OPTS="--no-color" \
    OPTAR="${AR}" \
    OPTCC="${CC}" \
    OPTCFLAGS="${CFLAGS}" \
    OPTLDFLAGS="${LDFLAGS}" \
    DESTDIR="${ED}" \
    prefix="${EPREFIX%/}" \
    bindir="${EPREFIX%/}/bin" \
    sysconfdir="${EPREFIX%/}"/etc \
    gitexecdir="${DPREFIX}/libexec/git-core" \
    sharedir="${DPREFIX}/share" \
    template_dir="${DPREFIX}/share/git-core/templates" \
    htmldir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV}/html \
    ASCIIDOC_NO_ROFF="YesPlease" \
    $(usex 'doc' ASCIIDOC8="YesPlease") \
    $(usex 'musl' NO_REGEX="NeedsStartEnd") \
    $(usex !cvs NO_CVS="YesPlease") \
    $(usex perl 'INSTALLDIRS=vendor NO_PERL_CPAN_FALLBACKS=YesPlease' NO_PERL="YesPlease") \
    $(usex !iconv NO_ICONV="YesPlease") \
    $(usex !nls NO_GETTEXT="YesPlease") \
    $(usex !perforce NO_PYTHON="YesPlease") \
    $(usex !subversion NO_SVN_TESTS="YesPlease") \
    $(usex !tk NO_TCLTK="YesPlease") \
    $(usex 'blksha1' BLK_SHA1="YesPlease") \
    $(usex !curl NO_CURL="YesPlease") \
    $(usex !webdav NO_EXPAT="YesPlease") \
    $(usex !openssl NO_OPENSSL="YesPlease") \
    NO_IPV6=$(usex !ipv6 "YesPlease") \
    $(usex "static" NO_INSTALL_HARDLINKS="YesPlease") \
    $(usex "pcre" USE_LIBPCRE2="YesPlease") \
    NO_FINK="YesPlease" \
    NO_DARWIN_PORTS="YesPlease" \
    INSTALL=install \
    TAR=tar \
    SHELL_PATH="${EPREFIX%/}/bin/sh" \
    SANE_TOOL_PATH= \
    OLD_ICONV= \
    NO_EXTERNAL_GREP= \
    LDFLAGS="$(usex static '-s -static --static ')${LDFLAGS}" \
    all strip install || die "Failed make build"

  cd "${ED}/" || die "install dir: not found... error"

  if ! use 'hardlink'; then
    # replace: hardlink -> symlink
    ln -sf /bin/${PN}             usr/libexec/git-core/
    ln -sf /bin/${PN}-shell       usr/libexec/git-core/
    ln -sf /bin/${PN}-upload-pack usr/libexec/git-core/
  fi
  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN} --version || die "binary work... error";}

  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
