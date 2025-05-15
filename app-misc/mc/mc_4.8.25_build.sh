#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-03-01 18:00 UTC - last change
# Build with useflag: -static -static-libs +shared -gpm -diet +musl +x32

export USER XPN PF PV WORKDIR S PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export BUILDLIST LIBDIR PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

NL="$(printf '\n\t')"; NL=${NL%?}
XPWD=${XPWD:-$PWD}
XPN=${PN}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PV="4.8.25"
DESCRIPTION="GNU Midnight Commander is a text based file manager"
HOMEPAGE="http://midnight-commander.org"
SRC_URI="http://ftp.midnight-commander.org/pub/midnightcommander/${PN}-${PV}.tar.xz"
LICENSE="GPL-3"
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
IUSE="+static +static-libs -rpath -nls -diet (+musl) (-patch) (-debug) -test -tests +strip"
IUSE="${IUSE} -shared -mclib +vfs +cpio +tar -subshell +charset +edit -diff"
IUSE="${IUSE} -gpm -nls -samba -smb +ftp -sftp -slang -spell +unicode -X -x +xdg +pcre +glib"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
SPREFIX="/"
EPREFIX=${SPREFIX}
XPWD=${5:-$XPWD}
P="${P:-${XPWD##*/}}"
SN=${P}
CATEGORY=${11:-$CATEGORY}
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
ZCOMP="unxz"
WORKDIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
S="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
XPN="${6:-${XPN:?}}"
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

#printf %s\\n "BUILDLIST='${BUILDLIST}'" "PV='${PV}'" "PKGNAME='${PKGNAME}'"

chroot-build || die "Failed chroot... error"

pkginst \
  "dev-libs/glib-compat" \
  "dev-libs/libffi" \
  "dev-libs/pcre" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc" \
  "sys-devel/make" \
  || die "Failed install build pkg depend... error"

if use 'diet'; then
  pkginst "dev-libs/dietlibc"
else
  pkginst "sys-libs/musl"
fi

use 'gpm' && pkginst "sys-libs/gpm"
use 'unicode' && pkginst "sys-libs/ncurses"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  rm -v /bin/groff /bin/help2man /bin/makeinfo /bin/msgfmt /bin/pod2html
  rm -v /bin/pod2man /bin/pod2text /bin/python /bin/soelim /bin/xsltproc

  ln -vs libglib-2.0.a "/$(get_libdir)/"libglib.a
fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit
elif test "X${USER}" != 'Xroot'; then
  renice -n '19' -u ${USER}

  #17-prefix_cmake.sh
  #17-python.sh
  : drop-python

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  #test -d "${WORKDIR}" && rm -rf -- "${WORKDIR}/"
  #emptydir "${ED}" || rm -r -- "${ED}/"*

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${WORKDIR}/" || die "workdir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  #patch -p1 -E < "${FILESDIR}"/${PN}-4.8.25-misc.diff

  #printf %s\\n "MAKEFLAGS='${MAKEFLAGS}'"
  #printf %s\\n "CC='${CC}'" "CXX='${CXX}'" "CPP='${CPP}'" "LIBTOOL='${LIBTOOL}'"
  #printf %s\\n "CFLAGS='${CFLAGS}'" "CPPFLAGS='${CPPFLAGS}'" "CXXFLAGS='${CXXFLAGS}'"
  #printf %s\\n "FCFLAGS='${FCFLAGS}'" "FFLAGS='${FFLAGS}'" "LDFLAGS='${LDFLAGS}'"

  export GLIB_LIBDIR="/$(get_libdir)"

  #if use 'static'; then
  #  export CC="gcc -static -static-libgcc -fno-exceptions"
  #  export CXX="g++ -static -static-libgcc -fno-exceptions"
  #  export LDFLAGS='-Wl,-static -static -lc'
  #  export LIBS='-lc'
  #fi
  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use 'static' || use 'static-libs'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections -static -static -lc
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  use 'static' && LD_LIBRARY_PATH=
  use 'strip' && INSTALL_OPTS="install-strip"
  use 'diet' && PATH="${PATH:+${PATH}:}/opt/diet/bin"

  IFS=${NL}

  . runverb \
  ./configure \
    GLIB_LIBDIR=${GLIB_LIBDIR} \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-homedir=$(usex 'xdg' XDG yes) \
    --with-pcre=$(usex 'pcre' yes no) \
    $(use_enable 'mclib') \
    $(use_enable 'shared') \
    $(use_enable 'static') \
    $(use_with 'static' glib-static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    --with-screen=$(usex 'unicode' ncursesw ncurses) \
    $(usex 'unicode' "--with-ncurses-libs=/$(get_libdir)") \
    $(use_with 'x') \
    $(use_enable 'spell' aspell) \
    $(use_enable 'subshell' background) \
    $(use_enable 'charset') \
    $(use_with 'diff' diff-viewer) \
    $(use_with 'edit' internal-edit) \
    $(use_with 'gpm' gpm-mouse) \
    --with-subshell=$(usex 'subshell' yes no) \
    $(use_enable 'tests') \
    --with-search-engine=$(usex 'glib' glib pcre) \
    $(use_enable 'vfs') \
    $(use_enable 'cpio' vfs-cpio) \
    $(use_enable 'tar' vfs-tar) \
    $(use_enable 'vfs' vfs-sfs) \
    $(use_enable 'vfs' vfs-extfs) \
    --disable-vfs-fish \
    $(use_enable 'smb' vfs-smb) \
    $(use_enable 'ftp' vfs-ftp) \
    $(use_enable 'sftp' vfs-sftp) \
    || die "configure... error"

  make -j "$(cpun)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || printf %s\\n "make install... error"

  cd "${WORKDIR}/misc/"
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install ${PN}-misc... error"

  cd "${ED}/" || die "install dir: not found... error"

  rm -r -- "usr/share/man/"

  if use 'static'; then
    LD_LIBRARY_PATH=
  elif use 'mclib'; then
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH} }:${INSTALL_DIR}/$(get_libdir)"
  fi
  bin/${PN} -V
  use 'diet' || { ldd "bin/${PN}" || { use 'static' && true;} ;}

  exit 0
fi

cd "${ED}/" || die "install dir: not found... error"

use 'diet' && { ldd "bin/${PN}" || { use 'static' && true;} ;}

pkg-perm

INST_ABI="$(tc-abi-build)" pkg-create-cgz
