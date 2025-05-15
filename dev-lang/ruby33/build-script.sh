#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-26 12:00 UTC - last change
# Date: 2024-10-12 09:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-lang/ruby/ruby-3.3.5.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="An object-oriented scripting language"
HOMEPAGE="https://www.ruby-lang.org/"
LICENSE="Ruby-BSD BSD-2"
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
PV="3.3.0"
PV="3.3.2"
PV="3.3.5"
SLOT=${PV%.*}
RUBYVER="${SLOT}.0"
MY_SUFFIX=${SLOT/.}  # no-posix
SRC_URI="
  http://cache.ruby-lang.org/pub/ruby/${SLOT}/${PN}-${PV}.tar.xz
  #http://data.gpo.zugaina.org/gentoo/dev-lang/ruby/files/3.3/010-default-gem-location.patch
  #http://data.gpo.zugaina.org/gentoo/dev-lang/ruby/files/3.3/011-arm64-branch-protection.patch
  https://data.gpo.zugaina.org/gentoo/dev-lang/ruby/files/3.3/013-test-rlimit-constants.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/ruby/files/3.3/902-hppa-pthread-stack-size.patch
  http://data.gpo.zugaina.org/gentoo/dev-lang/ruby/files/3.3/901-musl-stacksize.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared (+musl) (-man) -doc -debug (-test) +strip +stest"
IUSE="${IUSE} -rpath (-ncurses) (-readline) (-syslog) -valgrind -xemacs +berkdb"
IUSE="${IUSE} -examples +gdbm -jemalloc -jit -socks5 +ssl -systemtap -tk"
IUSE="${IUSE} -rdoc -rubytests (+zlib) -nopie +capi +rubygems -multiarch"
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
PKGNAME=${XPN}
ZCOMP="unxz"
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
  "dev-db/bdb6  # berkdb (optional)" \
  "dev-lang/perl" \
  "#dev-lang/ruby33" \
  "dev-libs/gmp" \
  "dev-libs/libffi" \
  "dev-libs/libyaml  # (optional)" \
  "dev-libs/openssl3  # for ssl (optional)" \
  "dev-util/pkgconf" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "#sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/gdbm0  # gdbm (optional)" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
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

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  modules="win32,win32ole"
  #use readline || modules=${modules},readline
  use 'berkdb'   || modules="${modules},dbm"
  use 'gdbm'     || modules="${modules},gdbm"
  use 'ssl'      || modules="${modules},openssl"
  use 'tk'       || modules="${modules},tk"
  #use ncurses  || modules=${modules},curses

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  # In many places aliasing rules are broken; play it safe
  # as it's risky with newer compilers to leave it as it is.
  append-flags -fno-strict-aliasing

  CC="cc" CXX="c++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #gpatch -p1 -E < "${FILESDIR}/010-default-gem-location.patch"
  #patch -p1 -E < "${FILESDIR}/011-arm64-branch-protection.patch"
  patch -p1 -E < "${FILESDIR}/013-test-rlimit-constants.patch"
  patch -p1 -E < "${FILESDIR}/902-hppa-pthread-stack-size.patch"
  patch -p1 -E < "${FILESDIR}/901-musl-stacksize.patch"

  #rm -r ext/* || die

  # bug: x32 no build
  #rm -r spec/ruby/optional/capi/ext/*

  # Remove bundled gems that we will install via PDEPEND, bug
  # 539700.
  rm -r gems/* || die
  > gems/bundled_gems || die

  # Avoid the irb default gemspec since we will install the normal gem
  # instead. This avoids a file collision with dev-ruby/irb.
  rm -- lib/irb/irb.gemspec || die

  # Remove tests that are known to fail or require a network connection
  rm -f test/ruby/test_process.rb test/rubygems/test_gem.rb || die
  rm -f test/ruby/test_process.rb test/rubygems/test_gem_path_support.rb || die
  rm -f test/rinda/test_rinda.rb test/socket/test_tcp.rb test/fiber/test_address_resolve.rb
  rm -f spec/ruby/library/socket/tcpsocket/initialize_spec.rb || die
  rm -f spec/ruby/library/socket/tcpsocket/open_spec.rb || die

  # Remove webrick tests because setting LD_LIBRARY_PATH does not work for them.
  rm -r tool/test/webrick || die

  # Avoid test using the system ruby
  sed -e '/test_dumb_terminal/aomit "Uses system ruby"' -i test/reline/test_reline.rb || die

  # Avoid testing against hard-coded blockdev devices that most likely are not available
  sed -e '/def blockdev/a@blockdev = nil' -i test/ruby/test_file_exhaustive.rb || die

  # Avoid tests that require gem downloads
  sed -e '/^\(test-syntax-suggest\|PREPARE_SYNTAX_SUGGEST\)/ s/\$(TEST_RUNNABLE)/no/' \
   -i common.mk

  # Avoid test that fails intermittently
  sed -e '/test_gem_exec_gem_uninstall/aomit "Fails intermittently"' \
   -i test/rubygems/test_gem_commands_exec_command.rb || die

  # Fix co-routine selection for x32, bug 933070
  # --with-coroutine=amd64  it needed for <muslx32> libc?

  INSTALL="${EPREFIX%/}/bin/install -c" LIBPATHENV="" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --program-suffix="${MY_SUFFIX}" \
    --with-soname="ruby${MY_SUFFIX}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --without-baseruby \
    --with-compress-debug-sections=no \
    --enable-pthread \
    $(usex !multiarch --disable-multiarch) \
    $(usex 'x32' --with-coroutine=amd64) \
    $(usex 'nopie' --disable-pie) \
    $(usex 'dln' --enable-dln) \
    $(usex !rubygems --disable-rubygems) \
    $(usex !capi --disable-install-capi) \
    --with-gmp \
    --with-out-ext="${modules}" \
    --enable-mkmf-verbose \
    $(use_with 'jemalloc' jemalloc) \
    $(use_enable 'jit' jit-support ) \
    $(use_enable 'jit' yjit) \
    $(use_enable 'jit' rjit) \
    $(use_enable 'socks5' socks) \
    $(use_enable 'systemtap' dtrace) \
    $(use_enable 'doc' install-doc) \
    $(use_enable 'static-libs' static) \
    $(use_enable 'static-libs' install-static-library) \
    $(use_with 'static-libs' static-linked-ext) \
    $(use_enable 'debug') \
    --enable-shared \
    --disable-rpath \
    ac_cv_func_qsort_r="no" \
    || die "configure... error"

  # Makefile is broken because it lacks -ldl
  rm -rf ext/-test-/popen_deadlock || die

  LD_LIBRARY_PATH="${BUILD_DIR}${LD_LIBRARY_PATH+:}${LD_LIBRARY_PATH}"

  make -j "$(nproc)" \
    EXTLDFLAGS="${LDFLAGS}" \
    MJIT_CFLAGS="${CFLAGS}" \
    MJIT_OPTFLAGS="" \
    MJIT_DEBUGFLAGS="" \
    || die "Failed make build"

  #rm -r ext/json || die
  rm -r lib/bundler* lib/rdoc/rdoc.gemspec || die

  MINIRUBY=$(echo -e 'include Makefile\ngetminiruby:\n\t@echo $(MINIRUBY)' | make -f - getminiruby)
  LD_LIBRARY_PATH="${BUILD_DIR}:${ED}/$(get_libdir)${LD_LIBRARY_PATH+:}${LD_LIBRARY_PATH}"

  export RUBYLIB="${BUILD_DIR}:${ED}/$(get_libdir)/ruby/${RUBYVER}"
  for D in $(find "${BUILD_DIR}/ext" -type d) ; do
    RUBYLIB="${RUBYLIB}:${D}"
  done

  # Create directory for the default gems
  GEM_HOME="${EPREFIX%/}/$(get_libdir)/ruby/gems/${RUBYVER}"
  mkdir -pm 0755 -- "${ED}/${GEM_HOME}/" || die "mkdir gem home failed"

  . runverb \
  make V=1 DESTDIR="${ED}" GEM_DESTDIR=${GEM_HOME} install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/"

  # Remove installed rubygems and rdoc copy
  rm -r -- "$(get_libdir)/ruby/${RUBYVER}/rubygems" || die "rm rubygems failed"
  rm -r -- "bin/"gem"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -r -- "$(get_libdir)/ruby/${RUBYVER}"/rdoc* || die "rm rdoc failed"
  rm -rf -- "bin/"bundle"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -- "bin/"bundler"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -- "bin/"ri"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -- "bin/"rdoc"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -v -- "bin/"*.lock

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
