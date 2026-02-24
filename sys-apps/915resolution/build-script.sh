#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Modify the video BIOS of the 800 and 900 series Intel graphics chipsets
# Homepage: https://915resolution.mango-lang.org
# License: Public Domain
# Depends: <deps>
# Date: 2026-02-07 23:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=915resolution

PN="915resolution"
PV="0.5.3"
SRC_URI="
  https://915resolution.mango-lang.org/${PN}-${PV}.tar.gz
  http://localhost/pub/distfiles/patch/915r_945GME.patch
"
IUSE="+static -shared -doc (+musl) +stest +strip"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
ZCOMP="gunzip"
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
LIBDIR="/${LIB_DIR}"
PROG="sbin/${PN}"

. "${PDIR%/}/etools.d/"build-functions

chroot-build || die "Failed chroot... error"

pkginst \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"  # only for user-build

build(){
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
  printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  if use !shared || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  sed -e 's|915resolution.c.new|915resolution.c|' -i "${FILESDIR}"/915r_945GME.patch
  patch -p1 -E < "${FILESDIR}"/915r_945GME.patch

  ${CC} ${CFLAGS} ${LDFLAGS} -o "${PN}" "${PN}.c" || die "Failed make build"

  mkdir -m 0755 -- "${ED}"/sbin/

  mv -v -n ${PN} -t "${ED}"/sbin/ || die "make install... error"
  mv -v -n dump_bios "${ED}"/sbin/915dump_bios

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all ${PROG}

  use 'stest' && { ${PROG} --help || : die "binary work... error";}
  ldd "${PROG}" || { use 'static' && true || die "library deps work... error";}
}