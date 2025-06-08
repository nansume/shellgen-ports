#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-05-29 14:00 UTC - last change
# Build with useflag: -static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/media-libs/openh264/openh264-2.6.0.ebuild

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX LD AR

DESCRIPTION="Cisco OpenH264 library and Gecko Media Plugin for Mozilla packages"
HOMEPAGE="https://www.openh264.org/ https://github.com/cisco/openh264"
LICENSE="BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*} PN=${PN%_[0-9]*}
XPN=${XPN:-$PN}
PV="2.6.0"
MOZVER="135"
GMP_COMMIT="1f5a2f07a565a9465c14d3a8b12f3202f83c775e"
SRC_URI="
  https://github.com/cisco/openh264/archive/v${PV}.tar.gz -> ${PN}-${PV}.tar.gz
  https://github.com/mozilla/gmp-api/archive/${GMP_COMMIT}.tar.gz -> gmp-api-Firefox${MOZVER}-${GMP_COMMIT}.tar.gz
  http://data.gpo.zugaina.org/gentoo/media-libs/openh264/files/openh264-2.3.0-pkgconfig-pathfix.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-cpu_flags_arm_neon -cpu_flags_x86_avx2 -plugin -test +utils"
IUSE="${IUSE} -static +static-libs +shared -doc (+musl) +stest +strip"
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
PROG="openh264enc"

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
  "#dev-lang/nasm  # no-support x32" \
  "sys-devel/binutils" \
  "sys-devel/gcc14" \
  "sys-devel/make" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl" \
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

  emakecmd() {
    CC="${CC}" CXX="${CXX}" LD="${LD}" AR="${AR}" \
    make V=Yes CFLAGS_M32="" CFLAGS_M64="" CFLAGS_OPT="" \
      PREFIX="${EPREFIX%/}" \
      LIBDIR_NAME="/$(get_libdir)" \
      SHAREDLIB_DIR="${EPREFIX%/}/$(get_libdir)" \
      INCLUDES_DIR="${EPREFIX%/}/usr/include/${PN}" \
      HAVE_AVX2=$(usex 'cpu_flags_x86_avx2' Yes No) \
      HAVE_GTEST=$(usex 'test' Yes No) \
      ARCH="$(tc-arch)" \
      ENABLEPIC="Yes" \
      $@
  }

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz; do
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++" LD="ld" AR="ar"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/openh264-2.3.0-pkgconfig-pathfix.patch

  ln -svf "/dev/null" "build/gtest-targets.mk" || die
  sed -e 's/$(LIBPREFIX)gtest.$(LIBSUFFIX)//g' -i Makefile || die

  sed -e 's/ | generate-version//g' -i Makefile || die
  sed -e 's|$FULL_VERSION|""|g' codec/common/inc/version_gen.h.template > \
   codec/common/inc/version_gen.h

  ln -s "${WORKDIR}"/gmp-api-${GMP_COMMIT} gmp-api || die

  myopts="ENABLE64BIT=No"
  case "${ABI}" in
    x32) myopts="USE_ASM=No";;
    *64) myopts="ENABLE64BIT=Yes";;
  esac

  emakecmd -j "$(nproc)" ${myopts} || die "Failed make build"
  use plugin && emakecmd ${myopts} plugin

  emakecmd DESTDIR="${ED}" ${myopts} install-shared install-static || die "make install... error"

  if use 'utils'; then
    mkdir -pm 0755 -- "${ED}/bin/"
    mv -n h264enc "${ED}"/bin/openh264enc || die "Install... error"
    mv -n h264dec "${ED}"/bin/openh264dec || die "Install... error"
    printf %s\\n "Install: ${PN}... ok"
  fi

  if use 'plugin'; then
    plugpath="/$(get_libdir)/nsbrowser/plugins/gmp-gmp${PN}/system-installed"
    insinto "${plugpath}"
    doins libgmpopenh264.so* gmpopenh264.info
    echo "MOZ_GMP_PATH=\"${plugpath}\"" >"${BUILD_DIR}"/98-moz-gmp-${PN}
    doenvd "${BUILD_DIR}"/98-moz-gmp-${PN}

cat <<EOF >"${BUILD_DIR}"/${PN}-${PV}.js
pref("media.gmp-gmp${PN}.autoupdate", false);
pref("media.gmp-gmp${PN}.version", "system-installed");
EOF

    insinto /$(get_libdir)/firefox/defaults/pref
    newins "${BUILD_DIR}"/${PN}-${PV}.js ${PN}-${PV/_p*/}.js

    insinto /$(get_libdir)/seamonkey/defaults/pref
    newins "${BUILD_DIR}"/${PN}-${PV}.js ${PN}-${PV/_p*/}.js
  fi

  cd "${ED}/" || die "install dir: not found... error"

  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
  use 'utils' && strip --verbose --strip-all "bin/"*
  strip --verbose --strip-all "$(get_libdir)/"lib${PN}.so.${PV}
  use 'static-libs' && strip --strip-unneeded "$(get_libdir)/"lib${PN}.a

  if use 'utils'; then
    use 'stest' && { bin/${PROG} --help || : die "binary work... error";}
    ldd "bin/${PROG}" || { use 'static' && true || die "library deps work... error";}
  else
    ldd "$(get_libdir)"/lib${PN}.so.${PV} || die "library deps work... error"
  fi

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz