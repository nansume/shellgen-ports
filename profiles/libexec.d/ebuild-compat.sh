set -e -u

func_helper() {
  local FUNCNAME=${1:?required: func_helper <funcname>}
  printf '%s\n' "${FUNCNAME}... load"
  command -v ${FUNCNAME} >/dev/null && { ${FUNCNAME} || return ;} || true
}

var_patches() {
  local IFS="$(printf '\n\t')"; IFS=${IFS%?}
  local patches=
  local V=

  for V in ${PATCHES-}; do
    #printf '%s\n' "var_patches: V='${V-}'"
    V=${V%%#*}
    V="${V%${V##*[![:blank:]]}}"
    [ -n "${V-}" ] || continue
    patches="${patches-}${patches:+${IFS}}${V}"
  done
  [ -n "${patches-}" ] && export PATCHES=${patches}
  return 0
}

lang_rm() {
  set +f
  local DIR
  local LANG
  for DIR in usr/share/locale/*/ usr/share/help/*/; do
    DIR=${DIR%/}
    LANG=${DIR##*/}
    case ${LANG} in '*') continue;; esac
    case ${DIR} in
      *'/locale/'*) use 'locale' && { use "lang-${LANG}" && continue;}
      ;;
      *'/help/'*) use 'help' && { use "lang-${LANG}" && continue;}
      ;;
    esac
    printf '%s\n' "lang-rm: 'lang-${LANG}'"
    rm -v -r -- "${DIR}"
  done

  [ -d "usr/share/locale" ] && { emptydir "usr/share/locale/" && rmdir -- usr/share/locale/;}
  [ -d "usr/share/help" ]   && { emptydir "usr/share/help/"   && rmdir -- usr/share/help/;}
}

default() { :;}
fowners() { chown $@;}
# fperms() - it exists
systemd_dounit() { :;}

#diropts -o ulogd -g ulogd
_diropts() { :;}

pkgins() { pkginst \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool6  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-util/byacc  # alternative a bison (posix)" \
  "dev-util/pkgconf" \
  "sys-apps/file" \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/lex  # alternative a flex (posix)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-kernel/linux-headers-musl" \
  "sys-libs/musl" \
  "sys-libs/zlib" \
  || die "Failed install build pkg depend... error"
}

#bundled_static_libs() { :;}

pre_build() {
  ( [ -x "/bin/python" ] && [ ! -d "/var/cache/python" ] ) && {
  if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
    mkdir -m 0755 -- "/var/cache/python/"
    chown ${BUILD_USER}:${BUILD_USER} "/var/cache/python/"
  fi
  }
  command -v bundled_static_libs >/dev/null || return 0
  [ x"${USER}" != x'root' ] && prepare; prepare() { :;}
  bundled_static_libs
}

unpack() {
  set +f
  for PF in ${@:-*.*}; do
    case ${PF} in
      '*'*) continue;;
      *.tar.gz|*.tgz) ZCOMP="gunzip";;
      *.tar.xz) ZCOMP="unxz";;
      *.tar.bz2) ZCOMP="bunzip2";;
      *) continue;;
    esac
    printf %s "${ZCOMP} -dc ${PF} | tar -C ${PDIR%/}/${SRC_DIR}/ -xkf -"
    ${ZCOMP} -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || exit &&
    printf %s\\n "    ... ok"
  done
}

prepare() {
  #command -v pkg_setup >/dev/null && pkg_setup
  func_helper "pkg_setup"
  { [ -x "/bin/cc" ] || [ -x "/bin/gcc" ]; } && {

  export CC="gcc" CXX="g++"
  export CC="cc" CXX="c++" CPP="gcc -E" AR="ar" RANLIB="ranlib"  #_LIBTOOL= _CPPFLAGS=

  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use !shared && { use 'static-libs' || use 'static' ;}; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  use 'static' && append-ldflags "-s -static --static"
  append-flags -DNDEBUG -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

  if use 'diet'; then
    PATH="${PATH:+${PATH}:}/opt/diet/bin"
    CC="diet -Os gcc -nostdinc"
    CPP="diet -Os gcc -nostdinc -E"  # bugfix: error: C preprocessor `gcc -E` fails sanity check

    [ -d "/opt/diet" ] && export DIETHOME="/opt/diet"
    CC="${CC} -I."  # add headers from build dir
    #CC="${CC} -I${DIETHOME}/include"  # 2025.04.20 - FIX: it comment, replace by <-isystem>
    CC="${CC} -isystem ${DIETHOME}/include"  # 2025.04.20
    CC="${CC} -I/usr/include"
    [ -d "/usr/include/libowfat" ] && CC="${CC} -I/usr/include/libowfat"
  fi
  }

  [ -x "/bin/bmake" ] && export MAKESYSPATH="/usr/share/mk/bmake"

  #command -v src_prepare >/dev/null && { src_prepare; return;} || true
  func_helper "src_prepare"
}

src_install() {
  command -v "make" >/dev/null || return 0
  make DESTDIR="${ED}" PREFIX="${EPREFIX%/}" MANPREFIX="/usr/share/man" ${TARGET_INST}
  [ $? -eq '0' ] || die "make install... error"
}

build() {
  if command -v src_configure >/dev/null; then
    src_configure
  elif [ -x "/bin/make" ]; then
  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    --disable-nls \
    --disable-rpath \
    || die "configure... error"
  fi

  if command -v src_compile >/dev/null; then
    set +e; src_compile; set -e
  elif [ -x "/bin/make" ]; then
    make -j "$(nproc)" || die "Failed make build"
  fi
  cd "${BUILD_DIR}/"

  #command -v src_test >/dev/null && src_test
  func_helper "src_test"

  command -v src_install >/dev/null && { src_install; return;}

  [ -x "/bin/make" ] && { make DESTDIR="${ED}" ${TARGET_INST} || die "make install... error";}
}

package() {
  echo "build phase... inst-perm"
  inst-perm

  test -d "usr" || mkdir -m 0755 "usr/" "usr/share/"
  test -d "usr/bin"   && mv -v -n "usr/bin" -t .
  test -d "usr/sbin"  && mv -v -n "usr/sbin" -t .
  test -d "include"   && mv -v -n "include" -t usr/
  test -d "share/doc" && mv -v -n "share/doc" -t usr/share/
  test -d "share/man" && mv -v -n "share/man" -t usr/share/

  command -V pre_package || true
  func_helper "pre_package"

  if use !doc; then
    [ -d "usr/share/doc" ] && rm -v -r -- "usr/share/doc/"
  fi
  if ! ( use 'man' || use 'info' ); then
    [ -d "usr/share/info" ] && rm -v -r -- "usr/share/info/"
    [ -d "usr/share/man" ] && rm -v -r -- "usr/share/man/"
  fi

  case ${TARGET_INST} in
    *'strip')
    ;;
    *)
      use 'strip' && pkg-strip
    ;;
  esac

  lang_rm && echo "lang_rm... ok"
  pre-perm && echo "pre-perm... ok"

  emptydir "usr/share/" && rmdir -- usr/share/
  emptydir "usr/"   && rmdir -- usr/
  emptydir "share/"   && rmdir -- share/
  #emptydir include/   && rmdir -- include/
  echo "emptydir clean... ok"

  [ -x "${PROG-}" ] || PROG="sbin/${PN}"
  [ -x "${PROG}" ] || PROG="usr/libexec/${PN}"

  #stest  # TODO: remove local var or change it to function.
  if [ -x "${PROG}" ]; then
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"
    LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)/${PN}"
    use 'stest' && { printf '%s\n' "/${PROG} ${STEST_OPT}"; ${PROG} ${STEST_OPT} || : die "binary work... error";}
    if [ -x "/bin/ldd" ]; then
      ldd "${PROG}" || { use 'static' && true || : die "library deps work... error";}
    fi
  fi
  echo "stest... ok"

  func_helper "pkg_postinst"
  command -v pkg_postrm >/dev/null && { pkg_postrm || return ;} || true
}

# compat with gentoo
_multilib_src_test() { :;}
_multilib_src_install_all() { :;}

set -a  # all-export vars

SHELL=${1:?required path to <build-script>}

# TIP: if run over . ${@}, then add pos param $1=path/path/prepkgs.sh
test "X$(id -un)" != 'Xroot' && shift  # fix

unset BOOT_IMAGE;           unset INIT;          unset INIT_LOGFILE
unset COUNTRY;              unset KMAP;          unset CONFONT
unset KMODLST;              unset KMOD_BLACKLIST
unset NEW_ROOT;             unset RC_ITEM;       unset ROOTDEV
unset TTY;                  unset TTYN;          unset TTYN_MAX
unset _BASH_LOADABLES_PATH; unset _ENV;          unset EDITOR
unset biosdevname;          unset max_loop;      unset real_root

IFS="$(printf '\n\t') "
OLDIFS=${IFS}
XPWD=${XPWD:-$PWD}; XPWD=${5:-$XPWD}
PKG_DIR="/pkg"
LC_ALL="C"
CATEGORY="${CATEGORY:-${11:?required <CATEGORY>}}"
PN="${PN:-${12:?required <PN>}}"; PN=${PN%%_*}
XPN=${XPN:-$PN}
PV=${PV-}
SRC_URI=${SRC_URI-}
IUSE="+static-libs +shared +nopie -doc (+musl) +stest +strip"
DOCS="AUTHORS ChangeLog NEWS README"
USE_BUILD_ROOT="0"; USE_BUILD_ROOT=${9:-$USE_BUILD_ROOT}
BUILD_CHROOT=${BUILD_CHROOT:-0}; BUILD_CHROOT="${7:-${BUILD_CHROOT:?}}"
PDIR=$(pkg-rootdir)
PWD=${PWD%/}; PWD=${PWD:-/}
DPREFIX="/usr"
INCDIR="${DPREFIX}/include"
TARGET_INST="install"
inst=${TARGET_INST}
INSTALL_OPTS=${TARGET_INST}
SRC_DIR="build"
EABI=$(tc-abi-build)
ABI=${EABI}
XABI=${EABI}
EPREFIX="/"
#P="${P:-${PN}-${PV}}"  # compat with gentoo
P="${P:-${XPWD##*/}}"
SN=${P}
PORTS_DIR=${PWD%/$P}
DISTDIR="/usr/distfiles"
DISTSOURCE="${PDIR%/}/sources"
FILESDIR=${DISTSOURCE}
INSTALL_DIR="${PDIR%/}/install"
ED=${INSTALL_DIR}  # compat with gentoo
D=${ED}  # compat with gentoo
SDIR="${PDIR%/}/${SRC_DIR}"
PF=$(pfname 'src_uri.lst' "${SRC_URI}")
PKGNAME=${PN}
ZCOMP="gunzip"
WORKDIR="${PDIR%/}/${SRC_DIR}"
S="${WORKDIR}/${PN}-${PV}"  # compat with gentoo
BUILD_DIR=${S}
T="${ED}/usr/share"  # compat with gentoo [ BUILD_DIR ? ]
LIB_DIR=$(get_libdir)
LIBDIR="/${LIB_DIR}"
PKG_CONFIG="pkgconf"
PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
ABI_BUILD="${ABI_BUILD:-${1:?}}"
AWK="awk"
STRIP="strip"
CMAKE_PREFIX_PATH="/${LIB_DIR}/cmake"
PROG=${PROG:-bin/$PN}
STEST_OPT="--version"

if use 'strip' && [ -n "${TARGET_INST-}" ]; then
  TARGET_INST="install-strip"
  test -x "/bin/cmake" && TARGET_INST="install/strip"
fi

if test "X${USER}" != 'Xroot'; then
  mksrc-prepare
elif test "${BUILD_CHROOT:=0}" -eq '0'; then
  PATH="${PATH:+${PATH}:}${PDIR}/misc.d:${PDIR}/etools.d"
elif test "${BUILD_CHROOT:=0}" -ne '0'; then
  PATH="$(xpath):${PDIR%/}/misc.d:${PDIR%/}/etools.d"
  printf %s\\n "PATH='${PATH}'" "PDIR='${PDIR}'"
fi

#printf %s\\n "\$0='${0}'" "\$1='${1}'" "\$2='${2}'"
#printf %s\\n "PWD='${PWD}'"

. "${PDIR%/}/etools.d/"build-functions

set -a
SHELL="/bin/sh" . ${SHELL} ${@}
set +a

var_patches  # normalize var

chroot-build || die "Failed chroot... error"

pkgins

build-deps-fixfind

. "${PDIR%/}/etools.d/"ldpath-apply
. "${PDIR%/}/etools.d/"path-tools-apply

netuser-fetch "${SRC_URI}" || die "Failed fetch sources... error"
pre_build
sw-user || die "Failed package build from user... error"  # only for user-build

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  exit  # only for user-build
elif test "X${USER}" != 'Xroot'; then  # only for user-build
  PF=$(pfname 'src_uri.lst' "${SRC_URI}")  # redefine for ${PF}, because use `bundled_static_libs()`
  ZCOMP=$(zcomp-as "${PF}")

  renice -n '19' -u ${USER}

  [ -x "/bin/python" ] && . "${PDIR%/}/etools.d/"epython

  [ -x "/bin/awk" ] && AWK="/bin/awk"  # required absolute path, otherwise may be: Segmentation fault
  [ -x "/bin/gawk" ] && AWK="gawk"

  cd "${FILESDIR}/" || die "distsource dir: not found... error"
  unpack "${PF}"

  cd "${BUILD_DIR}/" || die "builddir: not found... error"
  [ -n "${PATCHES-}" ] && epatch ${PATCHES}
  set -e
  prepare
  build

  cd "${ED}/" || die "install dir: not found... error"
  package && echo "package... ok"
  set -e

  exit 0  # only for user-build
fi

# here is: root, no-chroot

cd "${ED}/" || die "install dir: not found... error"

use 'diet' && ldd "${PROG}" || { use 'static' && true || : die "library deps work... error";}

pkg-perm

INST_ABI="$(test-native-abi)" PN=${XPN:-$PN} PV=${XPV:-$PV} pkg-create-cgz