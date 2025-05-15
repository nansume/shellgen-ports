#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-02-08 14:00 UTC - last change
# Build with useflag: -static -static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/sys-boot/grub/grub-2.12-r5.ebuild
# https://git.alpinelinux.org/aports/plain/main/grub/APKBUILD

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH PYTHON

DESCRIPTION="GNU GRUB boot loader"
HOMEPAGE="https://www.gnu.org/software/grub/"
LICENSE="GPL-3+ BSD MIT fonts? ( GPL-2-with-font-exception ) themes? ( CC-BY-SA-3.0 BitstreamVera )"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}
PV="2.06"
PV="2.12"
DEJAVU="dejavu-sans-ttf-2.37"
UNIFONT="unifont-15.0.06"
SRC_URI="
  http://ftp.gnu.org/gnu/grub/${PN}-${PV}.tar.xz
  mirror://gnu/unifont/${UNIFONT}/${UNIFONT}.pcf.gz
  #https://downloads.sourceforge.net/dejavu/${DEJAVU}.zip
  #https://dev.gentoo.org/~floppym/dist/${P}-bash-completion.patch.gz
  http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/gfxpayload.patch
  http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/grub-2.02_beta2-KERNEL_GLOBS.patch
  http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/grub-2.06-test-words.patch
  http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/grub-2.12-fwsetup.patch
  https://927826.bugs.gentoo.org/attachment.cgi?id=912891 -> grub-2.12-fix-x32-build.patch
  #http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/grub.default-4
  #http://data.gpo.zugaina.org/gentoo/sys-boot/grub/files/sbat.csv
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
IUSE="-device-mapper -doc -efiemu +fonts -mount -nls -sdl -test -themes -truetype -libzfs"
IUSE="${IUSE} +pcbios +xz +lzma -coreboot -efi-32 -efi-64 -emu -ieee1275 -loongson"
IUSE="${IUSE} -multiboot -qemu -qemu-mips -uboot -xen -xen-32 -xen-pvh +python"
IUSE="${IUSE} -static +shared (+musl) +stest +strip"
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
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
#PYTHON="true"  # FIX: python not found... error

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
  "app-arch/xz" \
  "dev-lang/perl  # required for autotools (optional)" \
  "dev-lang/python38  # for autogen (optional)" \
  "dev-libs/expat  # for python (optional)" \
  "dev-util/pkgconf" \
  "media-libs/freetype" \
  "media-fonts/unifont  # is it needed? replace to system-unifont (optional)" \
  "sys-apps/gawk  # fix: nocompat with busybox awk" \
  "sys-devel/autoconf  # required for autotools (optional)" \
  "sys-devel/automake  # required for autotools (optional)" \
  "sys-devel/binutils" \
  "sys-devel/bison" \
  "sys-devel/flex" \
  "sys-devel/gcc9" \
  "sys-devel/gettext  # required for autotools (optional)" \
  "sys-devel/libtool  # required for autotools (optional)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/ncurses  # is it needed? (optional)" \
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

  . "${PDIR%/}/etools.d/"epython

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  ZCOMP="gunzip" PF="${UNIFONT}.pcf.gz"
  ${ZCOMP} -dc -k "${PF}" > "${WORKDIR}/${UNIFONT}.pcf" || exit &&
  printf %s\\n "${ZCOMP} -dc -k ${PF} > ${WORKDIR}/${UNIFONT}.pcf"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -Os -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CFLAGS=$(printf %s " ${CFLAGS} " | sed 's/ -mx32 / /')
  CFLAGS=$(printf %s "${CFLAGS}" | sed 's/ -march=[^ ]* / /;s/^ *//;s/ *$//')

  CTARGET=${CHOST}
  HOSTTYPE='i386'
  OSTYPE=${OSTYPE%%-*}
  # FIX: var OSTYPE is empty
  OSTYPE="linux-gnu"
  use 'musl' && OSTYPE="linux-musl"

  if test "X${ABI}" = 'Xx86'; then
    # <i686> - target may be inappropriate?
    CTARGET=${CHOST}  # unknow to appropriate <CHOST> ?
  else
    CTARGET="${HOSTTYPE}-pc-${OSTYPE}"
    printf %s\\n "${CTARGET}"
  fi
  # required target: <i386-pc-linux-gnu>

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  patch -p1 -E < "${FILESDIR}"/gfxpayload.patch
  patch -p1 -E < "${FILESDIR}"/grub-2.02_beta2-KERNEL_GLOBS.patch
  patch -p1 -E < "${FILESDIR}"/grub-2.06-test-words.patch
  patch -p1 -E < "${FILESDIR}"/grub-2.12-fwsetup.patch

  # FIX: grub-2.12 fails to build on x32 (grub/efi/api.h:1117:3: error: X32 does not support <ms_abi> attribute)
  # FIX: https://bugs.gentoo.org/show_bug.cgi?id=927826
  case $(tc-abi-build) in
    'x32') patch -p1 -E < "${FILESDIR}"/grub-2.12-fix-x32-build.patch;;
  esac

  #patch -p1 -E < "${WORKDIR}"/grub-2.12-bash-completion.patch

  if use 'fonts'; then
    ln -s "${WORKDIR}/${UNIFONT}.pcf" unifont.pcf || die
  fi

  PYTHON="python3" sh ./autogen.sh

  # Avoid error due to extra_deps.lst missing from source tarball:
  #  make[3]: *** No rule to make target <grub-core/extra_deps.lst>, needed by <syminfo.lst>.  Stop.
  #echo "depends bli part_gpt" > grub-core/extra_deps.lst || die

  # Required to fix 2.12 build - (empty) file is missing from release
  > grub-core/extra_deps.lst || die

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sbindir="${EPREFIX%/}/sbin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/lib" \
    --datadir="${EPREFIX%/}"/usr/share \
    --infodir="${EPREFIX%/}"/usr/share/info/${PN}-${PV} \
    --target=$(usex 'pcbios' ${CTARGET} efi32) \
    $(use_enable 'xz' liblzma) \
    $(use_enable 'efiemu') \
    --disable-werror \
    --with-platform=$(usex 'pcbios' pc efi32) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -vr -- "usr/share/info/"

  rm -vr -- \
   "bin/grub-glue-efi" \
   "etc/grub.d/20_linux_xen" \
   "etc/grub.d/25_bli" \
   "etc/grub.d/30_uefi-firmware" \
   "sbin/grub-macbless" \
   "lib/grub/i386-pc/affs.mod"* \
   "lib/grub/i386-pc/afs.mod"* \
   "lib/grub/i386-pc/efiemu.mod"* \
   "lib/grub/i386-pc/exfat.mod"* \
   "lib/grub/i386-pc/minix"* \
   "lib/grub/i386-pc/part_apple.mod"* \
   "lib/grub/i386-pc/part_sun.mod"* \
   "lib/grub/i386-pc/part_sunpc.mod"* \
   "sbin/grub-sparc64-setup"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz
