#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2025-05-23 12:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-devel/gcc/gcc-14.2.1_p20250515.ebuild

# [ -f ./libgcc_s.so.1 ]; then mv -f ./libgcc_s.so.1 ./libgcc_s.so.1.backup; else true; fi && mv ./libgcc_s.so.1.tmp
# ./ibgcc_s.so.1 && (echo "/* GNU ld script"; echo
# "   Use the shared library, but some functions are only in"; echo "   the
# static library.  */"; echo "GROUP ( libgcc_s.so.1 -lgcc )" ) > ./libgcc_s.so
# /bin/ld: cannot find crti.o: No such file or directory
# /bin/ld: cannot find crtn.o: No such file or directory
# collect2: error: ld returned 1 exit status

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX CPP AR _PKG_CONFIG _PKG_CONFIG_LIBDIR _PKG_CONFIG_PATH _LIBS _LDCONFIG

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
PN=${PN%-stage1}
XPN=${PN}
PN=${PN%[0-9][0-9]}
PV="14.3.0"
PV="11.5.0"
SRC_URI="http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-system-zlib +openmp -libssp -sanitize -multilib +lto +asm +pic +cxx -libvtv -objc -go -rust"
IUSE="${IUSE} -bootstrap -rpath -nls +static +static-libs +shared -doc (+musl) +stest +strip"
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
#PKG_CONFIG="pkgconf"
#PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
#PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
IONICE_COMM="nice -n 19"

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
  "dev-libs/gmp" \
  "dev-libs/mpc" \
  "dev-libs/mpfr" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/libtool" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +x /bin/xutils-stub
  ln -sf xutils-stub /bin/makeinfo
fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
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
  if use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"
  CPP="gcc -E" AR="ar"

  use 'strip' && INSTALL_OPTS='install-strip'

  LANGCOMP="${LANGCOMP}$(usex 'go' ,go)"
  LANGCOMP="${LANGCOMP}$(usex 'rust' ,rust)"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  . runverb \
  ./configure \
    CC="${CC}" \
    CXX="${CXX}" \
    CPP="${CPP}" \
    AR="${AR}" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --target=$(tc-chost) \
    --disable-bootstrap \
    --with-gxx-include-dir="${INCDIR}/c++" \
    --enable-stage1-languages="c" \
    --enable-languages="c,c++${LANGCOMP}" \
    --with-default-libstdcxx-abi="gcc4-compatible" \
    --disable-decimal-float \
    --disable-libquadmath \
    --disable-libatomic \
    --disable-libmpx \
    --disable-libmudflap \
    --disable-cet \
    --disable-assembly \
    --enable-libiberty \
    $(use_enable 'openmp' libgomp) \
    $(use_enable 'lto') \
    $(use_enable 'libssp') \
    $(use_enable 'sanitize' libsanitizer) \
    $(use_enable 'multilib') \
    $(use_with 'system-zlib') \
    --disable-nls \
    --disable-libvtv \
    --enable-obsolete \
    --disable-gnu-indirect-function \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    $(usex 'static' "LDFLAGS=${LDFLAGS}") \
    || die "configure... error"

  make -j "$(nproc --ignore=1)" || die "Failed make build"

  . runverb \
  make -j1 DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  for X in bin/*-linux-musl-*; do
    case ${X##*/} in
      *'-linux-musl-c++')
        X=${X##*/}
        ln -vsf "${X%-*}-g++" "bin/${X}"
        ln -vsf "${X}" "bin/${X#*-linux-musl-}"
      ;;
      *"-linux-musl-gcc-${PV}")
        X=${X##*/}
        ln -vsf "${X}" "bin/${X%-*}"
      ;;
      *)
        ln -vsf "${X##*/}" "bin/${X#*-linux-musl-}"
      ;;
    esac
  done

  use 'doc' || rm -r -- "usr/share/man/" "usr/share/info/"

  # simple test
  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || : die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz