#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-10-12 17:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-lang/ruby/ruby-2.4.4-r1.ebuild?id=${HASH}

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
PV="2.6.10"
PV="2.4.10"
SLOT=${PV%.*}
RUBYVER="${SLOT}.0"
MY_SUFFIX=${SLOT/.}  # no-posix
HASH="56a6822d7da1a3623c6d0cc0ee05ddd6f81de958"
SRC_URI="https://gitweb.gentoo.org/repo/gentoo.git/plain/dev-lang/ruby/files/2.4"
SRC_URI="
  http://cache.ruby-lang.org/pub/ruby/${SLOT}/${PN}-${PV}.tar.xz
  ${SRC_URI}/005_no-undefined-ext.patch?id=${HASH}
  ${SRC_URI}/009_no-gems.patch?id=${HASH}
  ${SRC_URI}/011-gcc8.patch?id=${HASH}
  #${SRC_URI}/002-autoconf-2.70.patch?id=${COMMIT} -> 002-autoconf-2.70.patch
  #${SRC_URI}/010-default-gem-location.patch?id=${COMMIT} -> 010-default-gem-location.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-static -static-libs +shared (+musl) (-man) -doc -debug (-test) +stest +strip"
IUSE="${IUSE} -rpath (-ncurses) (-readline) (-syslog) -valgrind -xemacs +berkdb"
IUSE="${IUSE} -examples +gdbm +ipv6 -jemalloc +jit -socks5 +ssl -systemtap -tk"
IUSE="${IUSE} -rdoc -rubytests (+zlib) -nopie (+capi) +rubygems -multiarch -static-ext"
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
  "dev-db/bdb6  # berkdb (optional) it for ruby26?" \
  "dev-lang/perl" \
  "#dev-lang/ruby24" \
  "sys-devel/autoconf" \
  "sys-devel/automake" \
  "sys-devel/m4" \
  "dev-libs/gmp" \
  "dev-libs/libffi" \
  "dev-libs/libyaml  # (optional)" \
  "dev-libs/openssl  # for ssl (optional)" \
  "dev-util/pkgconf" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/gdbm0  # gdbm (optional)" \
  "#sys-libs/readline  # optional)" \
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

  modules=""
  use 'berkdb'   || modules="${modules},dbm"
  use 'gdbm'     || modules="${modules},gdbm"
  use 'ssl'      || modules="${modules},openssl"
  use 'tk'       || modules="${modules},tk"

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
  #append-ldflags "-Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic"
  append-flags -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  # In many places aliasing rules are broken; play it safe
  # as it's risky with newer compilers to leave it as it is.
  append-flags -fno-strict-aliasing

  CC="cc" CXX="c++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  for F in "${FILESDIR}/"*".patch"; do
    test -f "${F}" && gpatch -p1 -E < "${F}"
  done

  # Remove bundled gems that we will install via pkg depend, bug
  # 539700. Use explicit version numbers to ensure rm fails when they
  # change so we can update dependencies accordingly.
  rm -f gems/did_you_mean-1.1.0.gem gems/minitest-5.10.1.gem gems/net-telnet-0.1.1.gem || die
  rm -f gems/power_assert-0.4.1.gem gems/rake-12.0.0.gem gems/test-unit-3.2.3.gem gems/xmlrpc-0.2.1.gem || die
  #rm -r gems/* || die

  # bug: x32 no build, Removing bundled libraries...
  rm -r ext/fiddle/libffi-3.2.1 || die

  # Fix a hardcoded lib path in configure script
  sed -e "s:\(RUBY_LIB_PREFIX=\"\${prefix}/\)lib:\1$(get_libdir):" -i configure.in || die "sed failed"

  test -x "/bin/perl" && autoreconf --install

  INSTALL="${EPREFIX%/}/bin/install -c" LIBPATHENV="" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --program-suffix="${MY_SUFFIX}" \
    --with-soname="ruby${MY_SUFFIX}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --with-readline-dir="${EPREFIX%/}" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --mandir="${DPREFIX}/share/man" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --enable-pthread \
    --disable-multiarch \
    $(usex !rubygems --disable-rubygems) \
    --with-gmp \
    --with-out-ext="${modules}" \
    $(use_with 'jemalloc' jemalloc) \
    $(use_enable 'jit' jit-support ) \
    $(use_enable 'socks5' socks) \
    $(use_enable 'systemtap' dtrace) \
    $(use_enable 'doc' install-doc) \
    --enable-ipv6 \
    $(usex !ipv6 --with-lookup-order-hack=INET) \
    $(use_enable 'static-libs' static) \
    $(use_enable 'static-libs' install-static-library) \
    $(use_with 'static-ext' static-linked-ext) \
    $(use_enable 'debug') \
    --enable-shared \
    --disable-rpath \
    || die "configure... error"

  # Makefile is broken because it lacks -ldl
  #rm -rf ext/-test-/popen_deadlock || die

  #sed -e '/^LIBS = /s/-lssl -lcrypto/-Wl,-Bstatic -lssl -lcrypto -Wl,-Bdynamic/' -i ext/openssl/Makefile
  #exit 1

  LD_LIBRARY_PATH="${BUILD_DIR}${LD_LIBRARY_PATH+:}${LD_LIBRARY_PATH}"

  make -j "$(nproc)" EXTLDFLAGS="${LDFLAGS}" || die "Failed make build"

  # Remove the remaining bundled gems. We do this late in the process
  # since they are used during the build to e.g. create the
  # documentation.
  rm -r ext/json || die
  # Removing default gems before installation
  #rm -r lib/bundler* lib/rdoc/rdoc.gemspec || die

  MINIRUBY=$(echo -e 'include Makefile\ngetminiruby:\n\t@echo $(MINIRUBY)' | make -f - getminiruby)
  LD_LIBRARY_PATH="${BUILD_DIR}:${ED}/$(get_libdir)${LD_LIBRARY_PATH+:}${LD_LIBRARY_PATH}"

  export RUBYLIB="${BUILD_DIR}:${ED}/$(get_libdir)/ruby/${RUBYVER}"
  for D in $(find "${BUILD_DIR}/ext" -type d) ; do
    RUBYLIB="${RUBYLIB}:${D}"
  done

  # Create directory for the default gems
  #GEM_HOME="${EPREFIX%/}/$(get_libdir)/ruby/gems/${RUBYVER}"
  #mkdir -pm 0755 -- "${ED}/${GEM_HOME}/" || die "mkdir gem home failed"

  . runverb \
  make V=1 DESTDIR="${ED}" GEM_DESTDIR=${GEM_HOME} install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/"

  # Remove installed rubygems and rdoc copy
  rm -r -- "$(get_libdir)/ruby/${RUBYVER}/rubygems" || die "rm rubygems failed"
  rm -r -- "bin/"gem"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -r -- "$(get_libdir)/ruby/${RUBYVER}"/rdoc* || die "rm rdoc failed"
  rm -rf -v -- "bin/"bundle"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -v -- "bin/"bundler"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -v -- "bin/"ri"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -v -- "bin/"rdoc"${MY_SUFFIX}" || die "rm rdoc bins failed"
  rm -rf -v -- "bin/"*.lock

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
