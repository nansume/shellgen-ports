#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-08-31 18:00 UTC - last change
# Date: 2024-10-25 19:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://git.alpinelinux.org/aports/plain/community/exim/APKBUILD

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="A highly configurable, drop-in replacement for sendmail"
HOMEPAGE="https://www.exim.org/"
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
PV="4.96"
PV="4.98"
SRC_URI="
  https://ftp.exim.org/pub/exim/exim4/exim-${PV}.tar.xz
  #ftp://mirrors.tera-byte.com/pub/gentoo/distfiles/${PN}-${PV}.tar.xz
  #mirror://gentoo/system_filter.exim.gz
  #https://dev.gentoo.org/~grobian/distfiles/${PN}-4.96-gentoo-patches-r0.tar.xz
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/exim-4.14-tail.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/exim-4.97-as-needed-ldflags.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/exim-4.69-r1.27021.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/exim-4.97-localscan_dlopen.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/exim-4.97-no-exim_id_update.patch
  http://data.gpo.zugaina.org/gentoo/mail-mta/exim/files/auth_conf.sub
  https://git.alpinelinux.org/aports/plain/community/exim/bounce-charset.patch
  https://git.alpinelinux.org/aports/plain/community/exim/exim.Makefile
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-arc +berkdb -dane -dcc -dkim -dlfunc -dmarc -dnsdb -doc -dovecot-sasl"
IUSE="${IUSE} -dsn -gdbm -gnutls -idn +ipv6 -ldap -lmtp -maildir -mbx"
IUSE="${IUSE} -mysql -nis -pam -perl -pkcs11 -postgres -prdr -proxy -radius -redis -sasl -selinux"
IUSE="${IUSE} -socks5 -spf -sqlite -srs -ssl -syslog -tdb -tcpd -tpda -X"
IUSE="${IUSE} -static (+musl) +stest +strip"
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
  "dev-db/bdb5" \
  "#dev-db/sqlite" \
  "dev-lang/perl" \
  "dev-libs/pcre2" \
  "#dev-libs/libgcrypt" \
  "#dev-libs/libgpg-error" \
  "#dev-libs/libtasn1" \
  "#dev-libs/libunistring" \
  "#dev-libs/nettle" \
  "#dev-libs/openssl" \
  "#dev-libs/openssl-compat" \
  "#dev-libs/openssl3" \
  "#net-libs/gnutls" \
  "#sys-apps/findutils" \
  "sys-apps/gawk" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "#sys-libs/zlib" \
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

  for PF in *.tar.xz; do
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

  CC="cc$(usex static ' -static --static')"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #cp -n ${FILESDIR}/${PN}.Makefile Local/Makefile
  #for F in ../*-gentoo-patches-*/*.patch; do
  #  patch -p1 -E < "${F}"
  #done
  patch -p0 -E < "${FILESDIR}"/exim-4.14-tail.patch
  patch -p1 -E < "${FILESDIR}"/exim-4.97-as-needed-ldflags.patch # 352265, 391279
  patch -p1 -E < "${FILESDIR}"/exim-4.69-r1.27021.patch
  patch -p1 -E < "${FILESDIR}"/exim-4.97-localscan_dlopen.patch
  patch -p1 -E < "${FILESDIR}"/exim-4.97-no-exim_id_update.patch
  patch -p1 -E < "${FILESDIR}/bounce-charset.patch"

  # required gnu awk (no-posix)
  sed -e 's/ awk / gawk /' -i scripts/source_checks

  if use 'musl'; then
    sed -e 's/^LIBS = -lnsl/LIBS =/g' -i OS/Makefile-Linux || die
    export CFLAGS="${CFLAGS} -DNO_EXECINFO"
  fi

  sed \
    -e "s|^BIN_DIRECTORY=.*|BIN_DIRECTORY=/bin|" \
    -e "s|^CONFIGURE_FILE=.*|CONFIGURE_FILE=/etc/${PN}/${PN}.conf|" \
    -e "s|^EXIM_USER=$|EXIM_USER=ref:smtp|" \
    -e "s|^SPOOL_DIRECTORY=.*|SPOOL_DIRECTORY=/var/spool/mail|" \
    -e "s|.*DISABLE_TLS=.*|DISABLE_TLS=yes|" \
    -e "s|###.*USE_OPENSSL=.*|USE_OPENSSL=yes|" \
    -e "s|###.*USE_GNUTLS=.*|USE_GNUTLS=yes|" \
    -e "s|.*SUPPORT_MBX=.*|SUPPORT_MBX=yes|" \
    -e "s|^LOOKUP_DBM=.*|LOOKUP_CDB=yes|" \
    -e "s|^LOOKUP_LSEARCH=.*|LOOKUP_DSEARCH=yes|" \
    -e "s|^LOOKUP_DNSDB=.*|LOOKUP_PASSWD=yes|" \
    -e "s|^SUPPORT_DANE=.*||" \
    -e "s|###.*DISABLE_DKIM=.*|DISABLE_DKIM=yes|" \
    -e "s|.*DISABLE_PRDR=.*|DISABLE_PRDR=yes|" \
    -e "s|.*DISABLE_EVENT=.*|DISABLE_EVENT=yes|" \
    -e "s|###^FIXED_NEVER_USERS=.*|LOOKUP_CDB=yes|" \
    -e "s|###.*AUTH_PLAINTEXT=.*|AUTH_PLAINTEXT=yes|" \
    -e "s|^COMPRESS_COMMAND=.*|COMPRESS_COMMAND=gzip|" \
    -e "s|^ZCAT_COMMAND=.*|ZCAT_COMMAND=zcat|" \
    -e "s|^SYSTEM_ALIASES_FILE=.*|SYSTEM_ALIASES_FILE=/etc/mail/aliases|" \
    -e "s|.*HAVE_IPV6=.*|HAVE_IPV6=yes|" \
    src/EDITME > Local/Makefile

  make FULLECHO='' || die "Failed make build"

  cd "${BUILD_DIR}"/build-Linux-$(arch)/ || die

  mkdir -pm 0755 -- "${ED}"/etc/exim/ "${ED}"/bin/ "${ED}"/sbin/ "${ED}"/lib/
  mv -n ${PN} -t "${ED}"/sbin/ || die "make install... error"
  if use 'X'; then
    mv -n eximon.bin eximon -t "${ED}"/sbin/
  fi
  chmod 4755 -- "${ED}"/sbin/${PN}

  ln -s ${PN} "${ED}"/sbin/sendmail
  ln -s ${PN} "${ED}"/sbin/rsmtp
  ln -s ${PN} "${ED}"/sbin/rmail
  ln -s ../sbin/${PN} "${ED}"/bin/mailq
  ln -s ../sbin/${PN} "${ED}"/bin/newaliases
  ln -s ../sbin/sendmail "${ED}"/lib/sendmail

  PROGS="exicyclog exim_dbmbuild exim_dumpdb exim_fixdb exim_lock"
  PROGS="${PROGS} exim_tidydb exinext exiwhat exigrep eximstats exiqsumm"
  PROGS="${PROGS} exiqgrep convert4r3 convert4r4 exipick"
  PROGS=$(printf %s "${PROGS}" | sed 's| |\t|g')

  mv -n ${PROGS} -t "${ED}"/sbin/

  : dodoc -r "${BUILD_DIR}"/doc/.
  : doman "${BUILD_DIR}"/doc/exim.8
  #use dsn && dodoc "${BUILD_DIR}"/README.DSN
  #use doc && dodoc "${WORKDIR}"/${PN}-pdf-${PV//rc/RC}/doc/*.pdf

  # conf files
  mv -n "${BUILD_DIR}"/src/configure.default "${ED}"/etc/exim/exim.conf.dist
  : mv -n "${WORKDIR}"/system_filter.exim -t "${ED}"/etc/exim/
  use 'pam' && mv -n "${FILESDIR}"/auth_conf.sub -t "${ED}"/etc/exim/

  if use 'pam'; then
    : pamd_mimic system-auth exim auth account
  fi

  # headers, #436406
  if use 'dlfunc'; then
    mkdir -pm 0755 -- "${ED}"/usr/include/exim/
    # fixup includes so they actually can be found when including
    sed \
      -e '/#include "\(config\|store\|mytypes\).h"/s:"\(.\+\)":<exim/\1>:' \
      -i local_scan.h || die
    mv -n config.h local_scan.h -t "${ED}"/usr/include/exim/
    mv -n ../src/mytypes.h ../src/store.h -t "${ED}"/usr/include/exim/
  fi

  : insinto /etc/logrotate.d
  : newins "${FILESDIR}/exim.logrotate" exim

  : newinitd "${FILESDIR}"/exim.rc10 exim
  : newconfd "${FILESDIR}"/exim.confd exim

  : diropts -m 0750 -o ${MAILUSER} -g ${MAILGROUP}
  : keepdir /var/log/${PN}


  cd "${ED}/" || die "install dir: not found... error"

  strip --verbose --strip-all "sbin/${PN}" "sbin/${PN}_"*

  use 'static' && LD_LIBRARY_PATH=
  use 'stest' && { sbin/${PN} --version || die "binary work... error";}
  ldd "sbin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
