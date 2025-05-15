#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-09-18 21:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED CC

DESCRIPTION="Library and tools for managing linux kernel modules"
HOMEPAGE="https://git.kernel.org/pub/scm/utils/kernel/kmod/kmod.git"
LICENSE="LGPL-2"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PV="33"
PROG="bin/${PN}"
SRC_URI="https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kmod/${PN}-${PV}.tar.xz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-debug -doc -lzma -pkcs7 -static-libs +tools -zlib -zstd -static +shared (+musl) +stest +strip"
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
  "app-shells/bash  # need for sleep with time fraction (sec): sleep 0.01" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "#sys-libs/zlib  # optional" \
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
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc$(usex static ' --static')"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  if test ! -e "configure" || use 'doc'; then
    if use doc; then
      cp -n usr/share/aclocal/gtk-doc.m4 usr/share/aclocal/m4 || die
      : gtkdocize --copy --docdir libkmod/docs || die
    else
      >libkmod/docs/gtk-doc.make
    fi
    #test -x "/bin/perl" && autoreconf --install
  else
    : elibtoolize
  fi

  # Restore possibility of running --enable-static, bug #472608
  sed \
    -e '/--enable-static is not supported by kmod/s:as_fn_error:echo:' \
    -i configure || die

  /bin/bash ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'debug') \
    $(usex 'doc' --enable-gtk-doc) \
    $(use_enable 'tools') \
    $(use_with 'lzma' xz) \
    $(use_with 'pkcs7' openssl) \
    $(use_with 'zlib') \
    $(use_with 'zstd') \
    --disable-manpages \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -vr -- "usr/share/bash-completion/"

  find "$(get_libdir)/" -type f -name "*.la" -delete || die

  if use 'tools'; then
    mkdir -m 0755 -- "sbin/"
    for CMD in depmod insmod modprobe rmmod; do
      rm -- bin/${CMD} || die
      ln -vs ../bin/kmod sbin/${CMD}
    done

    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
    use 'static' && LD_LIBRARY_PATH=
    use 'stest' && { ${PROG} --version || die "binary work... error";}
    ldd ${PROG} || { use 'static' && true || die "library deps work... error";}
  fi

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} pkg-create-cgz
