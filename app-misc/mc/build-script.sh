#!/bin/sh
# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# Date: 2025-12-07 19:00 UTC - last change
# Build with useflag: +static -static-libs -mclib -shared +unicode +curses +pcre -gpm -diet +musl +x32

# http://data.gpo.zugaina.org/gentoo/app-misc/mc/mc-4.8.33.ebuild
# https://github.com/gavriva/mcstatic
# https://raw.githubusercontent.com/gavriva/mcstatic/master/build.sh

export XPN PF PV WORKDIR BUILD_DIR PKGNAME BUILD_CHROOT LC_ALL BUILD_USER SRC_DIR IUSE SRC_URI SDIR
export XABI SPREFIX EPREFIX DPREFIX PDIR P SN PN PORTS_DIR DISTDIR DISTSOURCE FILESDIR INSTALL_DIR ED
export CC CXX PKG_CONFIG PKG_CONFIG_LIBDIR PKG_CONFIG_PATH LIBS

DESCRIPTION="GNU Midnight Commander is a text based file manager"
HOMEPAGE="http://midnight-commander.org"
LICENSE="GPL-3"
IFS="$(printf '\n\t') "
XPWD=${XPWD:-$PWD}
XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"
PN=${PN%%_*}
XPN=${XPN:-$PN}
PN=${PN%[0-9]}  # for support a testing slot
PV="4.8.33"
PN1="musl"
PV1="1.2.5"
PN3="glib"
PV3="2.57.1"
XPV3="${PV%.*}"
PN4="zlib"
PV4="1.2.11"
SRC_URI="
  http://ftp.midnight-commander.org/${PN}-${PV}.tar.xz
  http://data.gpo.zugaina.org/gentoo/app-misc/mc/files/mc-4.8.26-ncurses-mouse.patch
  http://musl.libc.org/releases/${PN1}-${PV1}.tar.gz
  https://zlib.net/${PN4}-${PV4}.tar.xz
  ftp://ftp.acc.umu.se/pub/GNOME/sources/${PN3}/${XPV3}/${PN3}-${PV3}.tar.xz
  http://data.gpo.zugaina.org/didos/dev-libs/glib/files/2.56.2-quark_init_on_demand.patch
  http://data.gpo.zugaina.org/didos/dev-libs/glib/files/2.56.2-gobject_init_on_demand.patch
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
IUSE="+static -static-libs -shared -rpath -nls -doc (-diet) (+musl) -test -tests +stest +strip"
IUSE="${IUSE} -extfs -mclib +vfs +cpio +tar -subshell +charset +edit -diff"
IUSE="${IUSE} -gpm -nls +ftp -sftp -slang -ncurses +curses -spell +unicode -X -x (+xdg) +pcre +glib"
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
  "dev-libs/libffi" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl  # optional (too recomended)" \
  "sys-libs/netbsd-curses" \
  || die "Failed install build pkg depend... error"

use 'gpm' && pkginst "sys-libs/gpm"

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  printf '#!/bin/sh' > /bin/xutils-stub
  chmod +x /bin/xutils-stub
  ln -sf xutils-stub /bin/msgfmt
  chown ${BUILD_USER}:${BUILD_USER} "/$(get_libdir)/" "/usr/include/"
  chown ${BUILD_USER}:${BUILD_USER} -R "/usr/include/"
fi

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
sw-user || die "Failed package build from user... error"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  renice -n '19' -u ${USER}

  cd "${FILESDIR}/" || die "distsource dir: not found... error"

  for PF in *.tar.gz *.tar.xz; do
    case ${PF} in
      '*'.tar.*)  continue       ;;
       *.tar.gz)  ZCOMP="gunzip" ;;
       *.tar.xz)  ZCOMP="unxz"   ;;
    esac
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
  done

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2 ;;
    'x86')   append-flags -m32         ;;
    'amd64') append-flags -m64 -msse2  ;;
  esac
  append-flags -Os
  append-ldflags -Wl,--gc-sections
  append-cflags -ffunction-sections -fdata-sections
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

  CC="gcc" CXX="g++"

  use 'strip' && INSTALL_OPTS="install-strip"

  use 'shared' || {

  #############################################################################

  cd "${WORKDIR}/${PN1}-${PV1}/" || die "builddir: not found... error"

  ./configure \
    CC="${CC}" \
    CXX="c++" \
    AR="ar" \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --syslibdir="${EPREFIX%/}/$(get_libdir)" \
    --enable-wrapper=no \
    --disable-shared \
    --enable-static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  make DESTDIR="" install || die "make install... error"

  CFLAGS="${CFLAGS} -I${INCDIR}"
  LDFLAGS="${LDFLAGS} -L/$(get_libdir) -lc"

  ########################### build: <sys-libs/zlib> ##################################

  cd "${WORKDIR}/${PN4}-${PV4}/" || die "builddir: not found... error"

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --static \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN4}" install || die "make install... error"

  ########################### build: <sys-libs/netbsd-curses> ################################


  ########################### build: <dev-libs/glib57> ################################

  CC="${CC} -I${BUILD_DIR}/${PN4}/${INCDIR#/}"
  LIBS="${LIBS}${LIBS:+ }-L${BUILD_DIR}/${PN4}/$(get_libdir) -lz"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN4}/${LIB_DIR}/pkgconfig"

  cd "${WORKDIR}/${PN3}-${PV3}/" || die "builddir: not found... error"

  case $(tc-chost) in
    *'-linux-musl'*)  # Musl fix
      patch -p1 -E < "${FILESDIR}/2.56.2-quark_init_on_demand.patch"
      patch -p1 -E < "${FILESDIR}/2.56.2-gobject_init_on_demand.patch"
    ;;
  esac

  PYTHON="true" \
  ./configure \
    --prefix="${EPREFIX%/}/usr" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --disable-gtk-doc-html \
    --disable-fam \
    --disable-gtk-doc \
    --disable-libmount \
    --disable-man \
    --disable-xattr \
    --with-threads=posix \
    --disable-libelf \
    --disable-compile-warnings \
    --with-pcre="internal" \
    --enable-static \
    --disable-shared \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"
  make DESTDIR="${BUILD_DIR}/${PN3}" install || die "make install... error"

  ############################## build: <main-package> ####################################

  use 'shared' || append-ldflags "-s -static --static"
  }

  cd "${BUILD_DIR}/" || die "builddir: not found... error"

  printf %s\\n "Configure directory: PWD='${PWD}'... ok"

  patch -p1 -E < "${FILESDIR}"/${PN}-4.8.26-ncurses-mouse.patch

	use 'shared' || {

  #CC="${CC} -I${BUILD_DIR}/${PN2}/${INCDIR#/}"
  #PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN2}/lib/pkgconfig"
  LIBS="${LIBS}${LIBS:+ }-L/$(get_libdir) -lterminfo -lcurses -lform -lmenu -lpanel"

  # build: <dev-libs/glib57
  CC="${CC} -I${BUILD_DIR}/${PN3}/$(get_libdir)/${PN3}-2.0/include"
  CC="${CC} -I${BUILD_DIR}/${PN3}/${INCDIR#/}/${PN3}-2.0"
  CXX="${CXX}"
  PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${BUILD_DIR}/${PN3}/$(get_libdir)/pkgconfig"
  LIBS="${LIBS}${LIBS:+ }-L${BUILD_DIR}/${PN3}/$(get_libdir) -lglib-2.0"

  }

  ac_cv_search_stdscr=yes \
  ac_cv_search_has_colors=yes \
  GLIB_LIBDIR="$(usex !shared ${BUILD_DIR}/${PN3})/$(get_libdir)" \
  ./configure \
    --prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --libexecdir="${DPREFIX}/libexec" \
    --datarootdir="${DPREFIX}/share" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --with-pcre=$(usex 'pcre' yes no) \
    --disable-mclib \
    --disable-shared \
    --enable-static \
    $(use_with !shared glib-static) \
    $(use_enable 'nls') \
    $(use_enable 'rpath') \
    --with-screen=ncurses$(usex 'unicode' w) \
    $(usex 'shared' --with-ncurses-libs="$(usex !shared ${BUILD_DIR}/${PN2})/$(get_libdir)") \
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
    --disable-vfs-undelfs \
    --disable-vfs-extfs \
    $(use_enable 'vfs') \
    $(use_enable 'cpio' vfs-cpio) \
    $(use_enable 'tar' vfs-tar) \
    $(use_enable 'vfs' vfs-sfs) \
    $(use_enable 'ftp' vfs-ftp) \
    $(use_enable 'vfs' vfs-shell) \
    --disable-vfs-sftp \
    || die "configure... error"

  make -j "$(nproc)" || die "Failed make build"

  . runverb \
  make DESTDIR="${ED}" ${INSTALL_OPTS} || printf %s\\n "make install... error"

  cd "${BUILD_DIR}/misc/"
  make DESTDIR="${ED}" ${INSTALL_OPTS} || die "make install ${PN}-misc... error"

  cd "${ED}/" || die "install dir: not found... error"

  use 'doc' || rm -r -- "usr/share/man/"

  sed \
    -e 's/;cpio;/;cpio;cgz;clz;cxz;czst;/' \
    -e 's/;lsm;/;lsm;lst;/' \
    -e 's/;asm;/;arg;asm;/' \
    -e 's/;cgi;/;cgi;conf;/' \
    -e 's/;inc;/;inc;ipxe;/' \
    -e 's/;mly;/;mly;nft;/' \
    -e 's/;sas;/;sas;sed;/' \
    -e 's/;xq$/;xq;env;ebuild;lua/' \
    -e 's/;ogg;/;ogg;ogm;/' \
    -i etc/mc/filehighlight.ini

  sed \
    -e 's@Shell=.cpio.lzo$@Regex=\\\\.c(pio\\\\.lzo|lz)$@' \
    -e 's@Shell=.cpio.xz$@Regex=\\\\.c(pio\\\\.xz|xz)$@' \
    -e 's@Shell=.cpio.zst$@Regex=\\\\.c(pio\\\\.zst|zst)$@' \
    -e 's@Shell=.cpio.gz$@Regex=\\\\.c(pio\\\\.gz|gz)$@' \
    -e 's@mov|qt@ogm|mov|qt@' \
    -i etc/mc/mc.ext.ini

  sed \
    -e 's/cpio.gz)/cpio.gz|cgz)/' \
    -e 's/cpio.lzo)/cpio.lzo|clz)/' \
    -e 's/cpio.xz)/cpio.xz|cxz)/' \
    -e 's/cpio.zst)/cpio.zst|czst)/' \
    -i usr/libexec/mc/ext.d/archive.sh

  LD_LIBRARY_PATH=
  use 'stest' && { bin/${PN} -V || die "binary work... error";}

  exit 0  # only for user-build
fi

cd "${ED}/" || die "install dir: not found... error"

ldd "bin/${PN}" || { use 'static' && true || die "library deps work... error";}

pkg-perm

INST_ABI="$(tc-abi-build)" PN=${XPN} PV=${PV} pkg-create-cgz