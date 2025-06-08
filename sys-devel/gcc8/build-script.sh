#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2024-05-02 10:00 UTC, 2025-05-24 07:00 UTC - last change
# Build with useflag: +static +static-libs +shared -doc -xstub +musl +stest +strip +x32
# Usage [for bootstrap]: +bootstrap +downgrade +x32
# +static +static-libs +shared +openmp +lto -bootstrap -patch +asm -downgrade -doc +xstub +musl +stest +strip +x32

# stage1: +static +static-libs -shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-devel/gcc/gcc-14.2.1_p20250515.ebuild
# https://crux.nu/ports/crux-3.7/core/gcc/Pkgfile
# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=gcc-snapshot

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

DESCRIPTION="The GNU Compiler Collection"
HOMEPAGE="https://gcc.gnu.org/"
LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="8.5.0"
XPV=${PV%.*}
SRC_URI="
  http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}/${PN}-${PV}.tar.xz
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/01_all_default-fortify-source.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/07_all_libiberty-asprintf.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/09_all_nopie-all-flags.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/13_all_respect-build-cxxflags.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/15_all_libgomp-Werror.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/16_all_libitm-Werror.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/17_all_libatomic-Werror.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/18_all_libbacktrace-Werror.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/19_all_libsanitizer-libbacktrace-Werror.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/7.5.0/gentoo/20_all_libstdcxx-no-vtv.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/${PV}/gentoo/25_all_overridable_native.patch
  https://gitweb.gentoo.org/proj/gcc-patches.git/plain/${PV}/gentoo/33_all_msgfmt-libstdc++-link.patch
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
IUSE="-system-zlib +pic +cxx +openmp -libssp -sanitize -multilib +lto +asm -downgrade -libvtv -objc -gcj"
IUSE="${IUSE} -pch -nls -rpath +static +static-libs +shared -bootstrap -xstub -doc (+musl) +stest +strip"
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

use 'bootstrap' && tc-bootstrap-musl "$(arch)-linux-musl$(usex x32 x32 '')-native.tgz"

pkginst \
  "dev-libs/gmp" \
  "dev-libs/isl" \
  "dev-libs/mpc" \
  "dev-libs/mpfr" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' || {
  if pkg-is "sys-devel/gcc8" > /dev/null; then
    pkginst "sys-devel/gcc8"
  elif pkg-is "sys-devel/gcc9" > /dev/null; then
    pkginst "sys-devel/gcc9"
    USE="${USE} -shared"
  else
    pkginst "sys-devel/gcc"
    USE="${USE} -shared"
  fi
}

if pkg-is "dev-build/libtool8" > /dev/null; then
  pkginst "dev-build/libtool8"
elif pkg-is "dev-build/libtool9" > /dev/null; then
  pkginst "dev-build/libtool9"
elif pkg-is "dev-build/libtool" > /dev/null; then
  pkginst "dev-build/libtool"
fi

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +x /bin/xutils-stub
  ln -sf xutils-stub /bin/makeinfo
  ln -sf xutils-stub /bin/pod2man

  sw-user || die "Failed package build from user... error"
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  use 'static' && append-ldflags "-s -static --static"
  use 'shared' || USE="${USE} -pic"  # 2025.05.24 - testing
  #bug (no-build): -no-pie
  { use 'shared' || use 'pic' ;} || append-flags -no-pie
  append-flags -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  for F in ${SRC_URI}; do
    F=${F%\?id=*}; F="${FILESDIR}/${F##*/}"
    case "${F}" in
      *".patch") test -f "${F}" && gpatch -p1 -E < "${F}";;
    esac
  done

  . runverb \
  ./configure \
    CC="${CC}" \
    CXX="${CXX}" \
    CPP="cpp" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --with-gxx-include-dir="${INCDIR}/c++/${PV}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --target=$(tc-chost) \
    --disable-bootstrap \
    --enable-stage1-languages="c" \
    --enable-languages="c,c++" \
    $(use_enable 'openmp' libgomp) \
    $(use_enable 'lto') \
    $(use_enable 'libssp') \
    $(use_enable 'sanitize' libsanitizer) \
    $(use_enable 'multilib') \
    $(usex !pic --without-pic) \
    $(use_with 'system-zlib') \
    --with-abi=${EABI} \
    --disable-libvtv \
    --disable-vtable-verify \
    --enable-obsolete \
    --disable-gnu-indirect-function \
    $(usex !cxx --disable-hosted-libstdcxx) \
    $(usex !cxx --with-default-libstdcxx-abi="gcc4-compatible") \
    $(usex !cxx --disable-libstdcxx) \
    $(usex !cxx --disable-libstdcxx-threads) \
    $(usex !pch --disable-libstdcxx-pch) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    $(test -n "${LDFLAGS}" && printf %s "LDFLAGS=${LDFLAGS}") \
    || die "configure... error"

  make -j "$(nproc --ignore=0)" || die "Failed make build"

  ln -s "$(get_libdir)" "${ED}"/lib64

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -- "lib64/"

  GCC="$(tc-chost)-${PN}-${PV}"
  GXX="$(tc-chost)-g++"
  AR="$(tc-chost)-${PN}-ar"

  test -x "bin/${GCC}" &&
  for X in bin/${PN} bin/g++ bin/c++ bin/cpp bin/gcc-* bin/*-linux-musl*-*; do
    test -e "${X}" || continue
    X=${X##*/}
    case ${X} in
      *'-linux-musl'*'-gcc'|"gcc"|"cpp")
        ln -vsf "${GCC}" "bin/${X}"
      ;;
      *'-linux-musl'*'-c++'|"g++"|"c++")
        ln -vsf "${GXX}" "bin/${X}"
      ;;
      *"-linux-musl"*"-gcc-${PV}"|*'-linux-musl'*'-g++'|*'-linux-musl'*'-ar')
      ;;
      "gcc"|"cpp")
        ln -vsf "${GCC}" "bin/${X}"
      ;;
      "gcc-ar"|"gcc-nm"|"gcc-ranlib"|*"-gcc-nm"|*"-gcc-ranlib")
        ln -vsf "${AR}" "bin/${X}"
      ;;
    esac
  done
  ln -vsf "${GCC}" "bin/cc"

  use 'doc' || rm -v -r -- "usr/share/man/" "usr/share/info/"

  # simple test
  use 'stest' && { bin/${PN} --version || die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz