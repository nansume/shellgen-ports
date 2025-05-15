#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-29 19:00 UTC - last change
# Date: 2024-10-12 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED RUBY

DESCRIPTION="Centralized Ruby extension management system"
HOMEPAGE="https://rubygems.org/"
LICENSE="|| ( Ruby MIT )"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[1-4][0-9]}
PV="2.7.6"
PV="3.3.8"
#PV="3.0.9"
HASH="f246f6813abb1463274b9eace59895babce14a83"
SRC_URI="https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-ruby/rubygems"
SRC_URI="
  https://rubygems.org/rubygems/${PN}-${PV}.tgz -> ${PN}-${PV}.tar.gz
  ${SRC_URI}/files/gentoo-defaults-5.rb?id=${HASH} -> gentoo-defaults-5.rb  # 3.3.8
  #${SRC_URI}/files/gentoo-defaults-3.rb?id=${HASH} -> gentoo-defaults-3.rb  # 3.0.9
  ${SRC_URI}/files/auto_gem.rb.ruby19?id=${HASH} -> auto_gem.rb.ruby19
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-server -test"
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
SLOT="${XPN#${XPN%[1-4][0-9]}}"
RUBYSLOT="${SLOT%?}.${SLOT#?}"
RUBYVER="${RUBYSLOT}.0"
RUBY="/bin/ruby${RUBYSLOT/.}"  # no-posix

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
  "dev-db/bdb6  # berkdb (optional)" \
  "dev-lang/ruby${SLOT}" \
  "dev-libs/gmp" \
  "dev-libs/libffi" \
  "dev-libs/libyaml  # (optional)" \
  "#dev-libs/openssl3  # for ssl (optional), ruby33" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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

  inherit ruby-ng install-functions

  ruby_rbconfig_value() {
    echo $(${RUBY} -rrbconfig -e "puts RbConfig::CONFIG['$1']")
  }

  doruby() {
    test -z "${RUBY}" && die "\$RUBY is not set"
    EPREFIX=
    (
      sitelibdir=$(ruby_rbconfig_value 'sitelibdir')
      insinto ${sitelibdir#${EPREFIX%/}}
      doins "$@"
    ) || die "failed to install $@"
  }

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Remove unpackaged automatiek from Rakefile which stops it from working
  sed -e '/automatiek/ s:^:#:' -e '/Automatiek/,/^end/ s:^:#:' -i Rakefile || die  # 3.3.8

  mkdir -p lib/rubygems/defaults || die
  cp "${FILESDIR}/gentoo-defaults-5.rb" lib/rubygems/defaults/operating_system.rb || die
  #cp -n "${FILESDIR}/gentoo-defaults-3.rb" lib/rubygems/defaults/operating_system.rb || die  # 3.0.9

  sed -e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX%/}|g" -i lib/rubygems/defaults/operating_system.rb

  # Disable broken tests when changing default values:
  sed -e '/test_default_path/,/^  end/ s:^:#:' -i test/rubygems/test_gem.rb || die
  #sed -e '/test_env_shebang_flag/askip' -i test/rubygems/test_gem_commands_setup_command.rb  # 3.0.9
  sed -e '/test_initialize_\(path_with_defaults\|regexp_path_separator\)/aomit "gentoo"' \
   -i test/rubygems/test_gem_path_support.rb || die  # 3.3.8
  # Avoid test that won't work as json is also installed as plain ruby code
  sed -e '/test_realworld_\(\|upgraded_\)default_gem/aomit "gentoo"' -i test/rubygems/test_require.rb  # 3.3.8

  # Avoid test that requires additional utility scripts
  rm -f test/test_changelog_generator.rb || die  # 3.3.8

  # Not really a build but...
  sed -e 's:#!.*:#!'"${RUBY%[1-4][0-9]}"':' -i bin/gem

  export RUBYLIB="${PWD}/lib${RUBYLIB+:}${RUBYLIB}"

  cd "lib/"
  doruby -r *
  cd "${BUILD_DIR}/"

  sld=$(ruby_rbconfig_value 'sitelibdir')

  mkdir -m 0755 -- "${ED}"/bin/
  cp -n "${FILESDIR}/auto_gem.rb.ruby19" "${ED}"/"${sld#${EPREFIX%/}}"/auto_gem.rb
  mv -n -v bin/gem "${ED}"/bin/$(basename ${RUBY} | sed -e 's:ruby:gem:')

  : dodoc CHANGELOG.md README.md

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
