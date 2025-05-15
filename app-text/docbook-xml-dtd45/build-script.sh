#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-02 16:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet -musl -stest -strip +noarch

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="Docbook DTD for XML"
HOMEPAGE="https://docbook.org/"
LICENSE="docbook"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9][0-9]}
PN=${PN%-dtd}
PV="4.5"
SRC_URI="https://docbook.org/xml/${PV}/${PN}-${PV}.zip"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-doc"
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
ZCOMP="unzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR=${WORKDIR}
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
  "app-text/build-docbook-catalog" \
  "app-text/docbook-xsl-stylesheets" \
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

  inherit sgml-catalog-r1 desktop install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -q "${PF}" -d "${PDIR%/}/${SRC_DIR}/" || exit &&
  printf %s\\n "${ZCOMP} -q ${PF} -d ${PDIR%/}/${SRC_DIR}/"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  # Prepend OVERRIDE directive
  sed -e '1i\\OVERRIDE YES' -i docbook.cat || die

  : keepdir /etc/xml

  mkdir -pm 0755 -- "${ED}"/usr/share/sgml/docbook/xml-dtd-${PV}/
  mv -n *.cat *.dtd *.mod *.xml -t "${ED}"/usr/share/sgml/docbook/xml-dtd-${PV}/
  mkdir -pm 0755 -- "${ED}"/usr/share/sgml/docbook/xml-dtd-${PV}/ent/
  mv -n ent/*.ent -t "${ED}"/usr/share/sgml/docbook/xml-dtd-${PV}/ent/

cat > "xml-docbook-${PV}.cat" <<-EOF
CATALOG "${EPREFIX}/etc/sgml/sgml-docbook.cat"
CATALOG "${EPREFIX}/usr/share/sgml/docbook/xml-dtd-${PV}/docbook.cat"
EOF

  mkdir -pm 0755 -- "${ED}"/etc/sgml/
  mv -n "xml-docbook-${PV}.cat" -t "${ED}"/etc/sgml/

  cp -n ent/README README.ent
  dodoc ChangeLog README*

  cd "${ED}/" || die "install dir: not found... error"

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz
