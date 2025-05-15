#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-22 08:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/mail-mta/nullmailer/nullmailer-2.2-r2.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX AR RANLIB

DESCRIPTION="Simple relay-only local mail transport agent"
HOMEPAGE="http://untroubled.org/nullmailer/ https://github.com/bruceg/nullmailer"
LICENSE="GPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="2.2"
SRC_URI="
  http://untroubled.org/${PN}/archive/${PN}-${PV}.tar.gz
  http://data.gpo.zugaina.org/gentoo/mail-mta/nullmailer/files/nullmailer-2.2-fix-test-racecondition.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/nullmailer/files/nullmailer-2.2-disable-dns-using-test.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/nullmailer/files/nullmailer-2.2-disable-smtp-auth-tests.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/nullmailer/files/nullmailer-2.2-c++11.patch
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
IUSE="-ssl -test +static -doc (+musl) +stest +strip"
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
  "dev-lang/perl  # required for autotools" \
  "sys-devel/autoconf  # required for autotools" \
  "sys-devel/automake  # required for autotools" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
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

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

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
  AR="ar" RANLIB="ranlib"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-fix-test-racecondition.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-disable-dns-using-test.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-disable-smtp-auth-tests.patch"
  patch -p1 -E < "${FILESDIR}/${PN}-${PV}-c++11.patch"

  sed -i.orig \
   -e '/\$(localstatedir)\/trigger/d' \
   "${BUILD_DIR}"/Makefile.am || die
  sed \
   -e "s:^AC_PROG_RANLIB:AC_CHECK_TOOL(AR, ar, false)\nAC_PROG_RANLIB:g" \
   -i configure.ac || die
  sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.ac || die
  sed \
   -e "s#/usr/local#/usr#" \
   -e 's:/usr/etc/:/etc/:g' \
   -i doc/nullmailer-send.8 || die

  test -x "/bin/perl" && autoreconf --install

  # -Werror=odr
  # https://bugs.gentoo.org/859529
  # https://github.com/bruceg/nullmailer/issues/94
  : filter-lto

  # https://github.com/bruceg/nullmailer/pull/31/commits
  append-cppflags -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE  #471102

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --localstatedir="${EPREFIX}"/var \
    $(use_enable 'ssl' tls) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  # A small bit of sample config
  : insinto /etc/nullmailer
  : newins "${FILESDIR}"/remotes.sample-2.0 remotes

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/"
  rm -vr -- "etc/" "var/"

  # This contains passwords, so should be secure
  : fperms 0640 /etc/nullmailer/remotes
  : fowners root:nullmail /etc/nullmailer/remotes

  # daemontools stuff
  : dodir /var/spool/nullmailer/service{,/log}

  : insinto /var/spool/nullmailer/service
  : newins scripts/nullmailer.run run
  : fperms 700 /var/spool/nullmailer/service/run

  : insinto /var/spool/nullmailer/service/log
  : newins scripts/nullmailer-log.run run

  : fperms 700 /var/spool/nullmailer/service/log/run

  # usability
  mkdir -m 0755 -- "$(get_libdir)/"
  ln -s ../libexec/nullmailer/smtp sbin/sendmail
  ln -s ../sbin/sendmail $(get_libdir)/sendmail

  # permissions stuff
  : keepdir /var/log/nullmailer /var/spool/nullmailer/{tmp,queue,failed}
  : fperms 770 /var/log/nullmailer
  : fowners nullmail:nullmail /usr/sbin/nullmailer-queue /usr/bin/mailq
  : fperms 4711 /usr/sbin/nullmailer-queue /usr/bin/mailq

  : newinitd "${FILESDIR}"/init.d-nullmailer-r6 nullmailer

  #if ! test -e "${EROOT}/var/spool/nullmailer/trigger"; then
  #  mkfifo -m 0660 "${EROOT}/var/spool/nullmailer/trigger" || die
  #fi
  : chown nullmail:nullmail \
   "${EROOT}"/var/log/nullmailer \
   "${EROOT}"/var/spool/nullmailer/{tmp,queue,failed,trigger} || die
  : chmod 770 \
   "${EROOT}"/var/log/nullmailer \
   "${EROOT}"/var/spool/nullmailer/{tmp,queue,failed} || die
  : chmod 660 "${EROOT}"/var/spool/nullmailer/trigger || die

  # This contains passwords, so should be secure
  : chmod 0640 "${EROOT}"/etc/nullmailer/remotes || die
  : chown root:nullmail "${EROOT}"/etc/nullmailer/remotes || die

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { "bin/mailq" -- || : die "binary work... error";}
  ldd "bin/mailq" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
