#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-28 14:00 UTC - last change
# Build with useflag: +static +static-libs +shared -doc -xstub +musl +stest +strip +x32
# Usage [for bootstrap]: +bootstrap +downgrade +x32
# +static +static-libs +shared -openmp -lto -bootstrap +patch -asm +downgrade -doc -xstub +musl +stest +strip +x32

inherit build pkg-export build-functions

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${PN}
XPN="${6:-${XPN:?}}"
PN=${PN%[0-9]}
PV="9.5.0"
PV="8.3.0"
PV="8.2.0"
PV="7.5.0"
PV="6.4.0"
XPV=${PV%.*}
DESCRIPTION="The GNU Compiler Collection"
HOMEPAGE="https://gcc.gnu.org/"
I="git.alpinelinux.org/aports/plain/main/gcc"
GITHASH="0fa503e000050fa6c57ab8402f0b6643dfc18cc0"
SRC_URI="
  http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}/${PN}-${PV}.tar.xz
  #http://ftp.gnu.org/gnu/${PN}/${PN}-${PV}/${PN}-${PV}.tar.bz2
  http://sourceware.org/pub/java/ecj-4.9.jar
  #https://${I}/001_all_default-ssp-strong.patch?id=${GITHASH}
  #https://${I}/002_all_default-relro.patch?id=${GITHASH}
  #https://${I}/003_all_default-fortify-source.patch?id=${GITHASH}
  #https://${I}/005_all_default-as-needed.patch?id=${GITHASH}
  #https://${I}/011_all_default-warn-format-security.patch?id=${GITHASH}
  #https://${I}/012_all_default-warn-trampolines.patch?id=${GITHASH}
  https://${I}/020_all_msgfmt-libstdc++-link.patch?id=${GITHASH}
  #https://${I}/050_all_libiberty-asprintf.patch?id=${GITHASH}
  #https://${I}/051_all_libiberty-pic.patch?id=${GITHASH}
  #https://${I}/053_all_libitm-no-fortify-source.patch?id=${GITHASH}
  #https://${I}/067_all_gcc-poison-system-directories.patch?id=${GITHASH}
  #https://${I}/090_all_pr55930-dependency-tracking.patch?id=${GITHASH}

  #https://${I}/201-cilkrts.patch?id=${GITHASH}
  #https://${I}/203-libgcc_s.patch?id=${GITHASH}
  https://${I}/204-linux_libc_has_function.patch?id=${GITHASH}
  https://${I}/205-nopie.patch?id=${GITHASH}
  #https://${I}/207-static-pie.patch?id=${GITHASH}

  #https://${I}/libgcc-always-build-gcceh.a.patch?id=${GITHASH}
  #https://${I}/gcc-4.9-musl-fortify.patch?id=${GITHASH}
  #https://${I}/gcc-6.1-musl-libssp.patch?id=${GITHASH}
  https://${I}/boehm-gc-musl.patch?id=${GITHASH}
  #https://${I}/gcc-pure64.patch?id=${GITHASH}
  https://${I}/fix-gcj-stdgnu14-link.patch?id=${GITHASH}
  https://${I}/fix-gcj-musl.patch?id=${GITHASH}
  https://${I}/fix-gcj-iconv-musl.patch?id=${GITHASH}
  #https://${I}/gcc-4.8-build-args.patch?id=${GITHASH}
  #https://${I}/fix-cxxflags-passing.patch?id=${GITHASH}
  #https://${I}/ada-fixes.patch?id=${GITHASH}
  #https://${I}/ada-shared.patch?id=${GITHASH}
  #https://${I}/ada-musl.patch?id=${GITHASH}
  #https://${I}/ada-aarch64-multiarch.patch?id=${GITHASH}

  #https://${I}/300-main-gcc-add-musl-s390x-dynamic-linker.patch?id=${GITHASH}
  #https://${I}/310-build-gcj-s390x.patch?id=${GITHASH}
  https://${I}/320-libffi-gnulinux.patch?id=${GITHASH}

  #https://${I}/fix-rs6000-pie.patch?id=${GITHASH}
  #https://${I}/fix-linux-header-use-in-libgcc.patch?id=${GITHASH}
  #https://${I}/gcc-pure64-mips.patch?id=${GITHASH}
  #https://${I}/ada-mips64.patch?id=${GITHASH}

  #https://${I}/0001-i386-Move-struct-ix86_frame-to-machine_function.patch?id=${GITHASH}
  #https://${I}/0002-i386-Use-reference-of-struct-ix86_frame-to-avoid-cop.patch?id=${GITHASH}
  #https://${I}/0003-i386-Use-const-reference-of-struct-ix86_frame-to-avo.patch?id=${GITHASH}
  #https://${I}/0004-x86-Add-mindirect-branch.patch?id=${GITHASH}
  #https://${I}/0005-x86-Add-mfunction-return.patch?id=${GITHASH}
  #https://${I}/0006-x86-Add-mindirect-branch-register.patch?id=${GITHASH}
  #https://${I}/0007-x86-Add-V-register-operand-modifier.patch?id=${GITHASH}
  #https://${I}/0008-x86-Disallow-mindirect-branch-mfunction-return-with-.patch?id=${GITHASH}
  #https://${I}/0009-Use-INVALID_REGNUM-in-indirect-thunk-processing.patch?id=${GITHASH}
  #https://${I}/0010-i386-Pass-INVALID_REGNUM-as-invalid-register-number.patch?id=${GITHASH}
  #https://${I}/0011-i386-Update-mfunction-return-for-return-with-pop.patch?id=${GITHASH}
  #https://${I}/0012-i386-Add-TARGET_INDIRECT_BRANCH_REGISTER.patch?id=${GITHASH}
  #https://${I}/0013-i386-Don-t-generate-alias-for-function-return-thunk.patch?id=${GITHASH}
"
LICENSE="GPL-3+ LGPL-3+ || ( GPL-3+ libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.3+"
USER=${USER:-root}
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="linux"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="+static +static-libs +shared -bootstrap +patch -doc -system-zlib +stest +strip"
IUSE="${IUSE} -nls -rpath -pic -xstub"
IUSE="${IUSE} +openmp -libssp -sanitize -multilib +lto +asm -downgrade -libvtv +objc +gcj"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
P="${P:-${XPWD##*/}}"
SN=${P}
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
ZCOMP="bunzip2"
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
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
  "dev-libs/mpc" \
  "dev-libs/mpfr" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/libtool6" \
  "sys-devel/m4" \
  "sys-devel/make" \
  "sys-kernel/linux-headers" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

use 'bootstrap' ||
pkginst \
  "#sys-devel/gcc" \
  "#sys-devel/gcc8-gamma" \
  "sys-devel/gcc8" \
  "#sys-devel/gcc7" \
  "#sys-devel/gcc6" \
  "#sys-libs/musl"

pkginst \
  "sys-apps/findutils" \
  "dev-util/pkgconf" \
  "#sys-libs/zlib" \
  "sys-apps/file" \
  "sys-apps/coreutils  #" \
  "sys-apps/gawk" \
  "dev-lang/perl" \
  "sys-devel/autoconf  #" \
  "dev-libs/libxml2" \
  "sys-devel/gettext" \
  "sys-devel/automake  #"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  PVER="8.3.0"
  #ln -sf libc-2.28.so /lib/libc.so
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +X /bin/xutils-stub
  ln -sf xutils-stub /bin/makeinfo
  #ln -sf xutils-stub /bin/pod2man
  #ln -sf xutils-stub /bin/perl

  #rm -- bin/makeinfo
  ##rm -- bin/help2man bin/man bin/msgfmt bin/groff bin/python misc.d/groups
  ##rm -- bin/pod2html bin/pod2man bin/pod2text bin/soelim bin/xsltproc

  ln -sf $(tc-chost)-g++ /bin/c++
  ln -sf $(tc-chost)-${PN}-${PVER} /bin/cpp
  ln -sf $(tc-chost)-${PN}-ar /bin/${PN}-nm
  ln -sf $(tc-chost)-${PN}-ar /bin/${PN}-ranlib
  ln -sf $(tc-chost)-${PN}-ar /bin/$(tc-chost)-${PN}-nm
  ln -sf $(tc-chost)-${PN}-ar /bin/$(tc-chost)-${PN}-ranlib

  sw-user || die "Failed package build from user... error"
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  use 'patch' &&
  for F in ${SRC_URI}; do
    F=${F%\?id=*}; F="${FILESDIR}/${F##*/}"
    case "${F}" in
      *".patch") test -f "${F}" && patch -p1 -E < "${F}";;
    esac
  done

  #use 'downgrade' && IUSE="${IUSE} -lto"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
    use 'static' && append-ldflags "-s -static --static"
  else
    append-flags -O2
  fi
  #bug (no-build): -no-pie
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  # gcc8 -> gcc7
  # bugfix it:  error: converting to 'bool' from 'std::nullptr_t'
  #use 'downgrade' && append-cxxflags -std=gnu++03
  #use 'downgrade' && append-cxxflags -fexceptions
  #use 'downgrade' && append-cflags -std=gnu99
  #use 'downgrade' && append-cxxflags -fpermissive

  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"

  #unset CPPFLAGS FFLAGS FCFLAGS

  use 'strip' && INSTALL_OPTS='install-strip'

	IFS=${NL}

	: mkdir -m 0755 "${WORKDIR}/build/"

	: cd "${WORKDIR}/build/" || die "workdir: not found... error"

  #--enable-languages=c,c++ \
  #--disable-decimal-float \
  #--disable-libquadmath \
  #--disable-libatomic \
  #--disable-libmpx \
  #--disable-libmudflap \
  #--disable-cet \
  #--disable-assembly \
  #--enable-libiberty \

  : .."/libstdc++-v3/"configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --with-gxx-include-dir="${INCDIR}/c++/${PV}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --target=$(tc-chost) \
    $(use_enable 'multilib') \
    $(use_with 'pic') \
    --disable-vtable-verify \
    --with-default-libstdcxx-abi="gcc4-compatible" \
    --disable-hosted-libstdcxx \
    --disable-libstdcxx-threads \
    --disable-libstdcxx-pch \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    $(test -n "${LDFLAGS}" && printf %s "LDFLAGS=${LDFLAGS}") \
    || die "libstdc++-v3: configure... error"

  : make -j "$(nproc --ignore=0)" || die "libstdc++-v3: Failed make build"

  : cd "${WORKDIR}/" || die "workdir: not found... error"

	#filter-flags -std=gnu++03

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
    $(use_with 'pic') \
    $(use_with 'system-zlib') \
    --with-abi=${EABI} \
    --disable-libvtv \
    --disable-vtable-verify \
    --enable-obsolete \
    --disable-gnu-indirect-function \
    --disable-hosted-libstdcxx \
    --with-default-libstdcxx-abi="gcc4-compatible" \
    --disable-libstdcxx \
    --disable-libstdcxx-threads \
    --disable-libstdcxx-pch \
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
  make DESTDIR="${ED}" ${INSTALL_OPTS} || : die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -- lib64

  #for X in lib*; do
  #  test -d "${X}" || continue
  #  case ${X} in
  #    "libx32") continue;;
  #  esac
  #  mv -vn "${X}/"*.so* $(get_libdir)/
  #  rmdir "${X}/"
  #done

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
        #ln -vsf "gcc" "bin/${X#*-linux-musl-}"
      ;;
      *'-linux-musl'*'-c++'|"g++"|"c++")
        ln -vsf "${GXX}" "bin/${X}"
      ;;
      *"-linux-musl"*"-gcc-${PV}"|*'-linux-musl'*'-g++'|*'-linux-musl'*'-ar')
        #X=${X##*/}
        #ln -vsf "${GCC}" "bin/${X%-*}"
        #ln -vsf "gcc" "bin/${X}"
      ;;
      "gcc"|"cpp")
        ln -vsf "${GCC}" "bin/${X}"
      ;;
      "gcc-ar"|"gcc-nm"|"gcc-ranlib"|*"-gcc-nm"|*"-gcc-ranlib")
        ln -vsf "${AR}" "bin/${X}"
      ;;
      #?*)
      #  ln -vsf "${X##*/}" "bin/${X#*-linux-musl*-}"
      #;;
    esac
  done
  ln -vsf "${GCC}" "bin/cc"

  use 'doc' || rm -r -- "usr/share/man" "usr/share/info"

  pkg-rm-empty

  # simple test
  if use 'static'; then
    LD_LIBRARY_PATH=
  else
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  fi
  use 'stest' && { bin/${PN} --version || : die "binary work... error";}
  ldd "bin/${PN}" || { use 'static' && true || : die "library deps work... error";}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
