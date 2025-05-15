#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2024-11-02 16:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie +patch -doc -xstub -diet -musl -stest -strip +noarch

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED

DESCRIPTION="XSL Stylesheets for Docbook"
HOMEPAGE="https://github.com/docbook/wiki/wiki"
LICENSE="BSD"
IFS="$(printf '\n\t')"
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN="docbook-xsl"
PV="1.79.2"
SRC_URI="
  https://github.com/docbook/xslt10-stylesheets/releases/download/release/${PV}/${PN}-${PV}.tar.bz2
  http://data.gpo.zugaina.org/gentoo/app-text/${PN}-stylesheets/files/nonrecursive-string-subst.patch
"
USE_BUILD_ROOT="0"
BUILD_CHROOT=${BUILD_CHROOT:-0}
PDIR=$(pkg-rootdir)
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
HOSTNAME="localhost"
BUILD_USER="tools"
SRC_DIR="build"
IUSE="-ruby -doc"
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
ZCOMP="bunzip2"
WORKDIR="${PDIR%/}/${SRC_DIR}"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
PWD=${PWD%/}; PWD=${PWD:-/}
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
DOCBOOKDIR="/usr/share/sgml/${XPN/-//}"

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
  "dev-ruby/rexml  # ruby" \
  "sys-apps/findutils  # bb <find> no-compat - required replace shared to static and remove libc" \
  "sys-devel/patch  # for patch with fuzz and offset." \
  "sys-libs/musl  # for findutils" \
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

  inherit ruby-single desktop install-functions

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  gpatch -p1 -E < "${FILESDIR}"/nonrecursive-string-subst.patch

  # Delete the unnecessary Java-related stuff and other tools as they
  # bloat the stage3 tarballs massively. See bug #575818.
  rm -rv -- "extensions/" "tools/" || die
  /bin/find \( -name build.xml -o -name build.properties \) -printf "removed %p\n" -delete || die

  if ! use 'ruby'; then
    rm -rv -- "epub/" || die
  fi

  # The makefile runs tests, not builds.

  # The changelog is now zipped, and copied as the RELEASE-NOTES, so we
  # don't need to install it
  dodoc AUTHORS BUGS NEWS README RELEASE-NOTES.txt TODO

  insinto ${DOCBOOKDIR}
  doins VERSION VERSION.xsl

  for i in */; do
    i=${i%/}

    for doc in ChangeLog README; do
      if test -e "${i}/${doc}"; then
        newdoc ${i}/${doc} ${doc}.${i}
        rm -- "${i}/${doc}/" || : die
      fi
    done

    doins -r ${i}
  done || die "make install... error"

  cd "${ED}/" || die "install dir: not found... error"

  if use 'ruby'; then
    cmd="dbtoepub${MY_PN#docbook-xsl}"

    # we can't use a symlink or it'll look for the library in the wrong path
    cat > bin/${cmd} <<-EOF
#!/bin/ruby

load "${EPREFIX}${DOCBOOKDIR}/epub/bin/dbtoepub"
EOF
  fi

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="all" PN=${XPN} PV=${PV} pkg-create-cgz
