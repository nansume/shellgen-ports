#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-04-06 18:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/dev-lang/ocaml/ocaml-5.3.0-r1.ebuild
# https://git.alpinelinux.org/aports/plain/main/ocaml5/APKBUILD

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH

DESCRIPTION="Programming language supporting functional, imperative & object-oriented styles"
HOMEPAGE="https://ocaml.org/"
LICENSE="QPL-1.0 LGPL-2"
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
PV="5.3.0"
SRC_URI="https://github.com/ocaml/ocaml/archive/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
INSTALL_OPTS="install"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-emacs -flambda -latex -ocamlopt -test -xemacs +static-libs +shared -doc (+musl) +stest +strip"
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
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
PROG="ocamlrun"

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
  "#app-emacs/ocaml-mode  # emacs" \
  "#app-xemacs/ocaml  # xemacs" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl0" \
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
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  #cp "${FILESDIR}"/ocaml.conf "${T}" || die

  # OCaml generates textrels on 32-bit arches
  # We can't do anything about it, but disabling it means that tests
  # for OCaml-based packages won't fail on unexpected output
  # bug #773226
  if use 'arm' || use 'ppc' || use 'x86'; then
    append-ldflags "-Wl,-z,notext"
  fi

  # Upstream build ignores LDFLAGS in several places.
  sed \
   -e 's/\(^MKDLL=.*\)/\1 $(LDFLAGS)/' \
   -e 's/\(^OC_CFLAGS=.*\)/\1 $(LDFLAGS)/' \
   -e 's/\(^OC_LDFLAGS=.*\)/\1 $(LDFLAGS)/' \
   -i Makefile.config.in || die "LDFLAGS fix failed"

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)/${PN}" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --enable-native-compiler \
    --enable-native-toplevel \
    --disable-installing-bytecode-programs \
    --without-zstd \
    $(use_enable 'test' ocamltest) \
    $(use_enable 'flambda') \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  make -j "$(nproc)" world || die "Failed make build"

  #MKTARGET="world.opt"

  # BUG: no support x32 abi
  #  File "/build/ocaml-5.3.0/asmcomp/amd64/selection.ml", line 137, characters 46-58:
  #  Error: Integer literal exceeds the range of representable integers of type "int"
  #  make[3]: *** [Makefile:2541: asmcomp/selection.cmo] Error 2
  #use 'x32' && MKTARGET="world"  # FIX: for x32 abi

  #make -j "$(nproc)" ${MKTARGET} || die "Failed make build"

  if use !x32 && use 'ocamlopt'; then
    make -j "$(nproc)" opt || printf %s\\n "make opt... Error"
    make -j "$(nproc)" opt.opt || printf %s\\n "make opt.opt... Error"
  fi

  # OCaml generates textrels on 32-bit arches
  if use 'arm' || use 'ppc' || use 'x86'; then
    export QA_TEXTRELS='.*'
  fi

  make DESTDIR="${ED}" install || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  dodir /usr/include
  # Create symlink for header files
  dosym "../../$(get_libdir)/ocaml/caml" /usr/include/caml
  #dodoc Changes README.adoc

  use 'doc' || rm -r -- usr/share/doc/ usr/share/man/ usr/share/

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
  use 'stest' && { bin/${PROG} -version || die "binary work... error";}
  ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz