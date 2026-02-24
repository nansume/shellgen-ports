#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: A Minimal Curses IRC Client
# Homepage: http://c9x.me/git/irc.git/tree/
# License: <license>
# Depends: <deps>
# Date: 2026-02-04 14:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# https://aur.archlinux.org/packages/ircc

PN="${PN:-${12:?required <PN>}}"; PN=${PN%%_*}; XPN=${XPN:-$PN}
PV="2023.02.02"
HASH="17fc6b5c307623fb94a2b5179e5732119a08704f"
SRC_URI="
  http://c9x.me/git/irc.git/plain/irc.c?id=${HASH} -> ${PN}-irc.c
  http://c9x.me/git/irc.git/plain/Makefile?id=${HASH} -> ${PN}-Makefile
  http://c9x.me/git/irc.git/plain/README?id=${HASH} -> ${PN}-README
  #git://c9x.me/irc.git -> irc-${PV}.tar.gz
"
IUSE="+static -shared -doc (+musl) +stest +strip"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${PN}-${PV}"
BIN="irc"
PROG="bin/${BIN}"

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
  "dev-libs/gmp  # deps openssl" \
  "dev-libs/openssl1" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "sys-libs/netbsd-curses" \
  "sys-libs/zlib  # deps openssl" \
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

  mkdir -p -m 0755 -- "${BUILD_DIR}/"
  cp -v ${PN}-irc.c "${BUILD_DIR}/"irc.c
  cp -v ${PN}-Makefile "${BUILD_DIR}/"Makefile
  cp -v ${PN}-README "${BUILD_DIR}/"README

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && use 'static'; then
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

  sed -e 's|-lncursesw|-lcurses -lterminfo|' -i Makefile

  make -j "$(nproc)" || die "Failed make build"

  mkdir -m 0755 -- "${ED}"/bin/
  cp ${BIN} -t "${ED}"/bin/  || die "make install... error"
  chmod +x "${ED}"/bin/${BIN}

  cd "${ED}/" || die "install dir: not found... error"

  use 'strip' && strip --verbose --strip-all ${PROG}

  use 'stest' && { ${PROG} --version || die "binary work... error";}
  ldd "${PROG}" || { use 'static' && true || die "library deps work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz