#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +x32

DESCRIPTION="Old Imake-related build files"
HOMEPAGE="https://www.x.org/wiki/ https://gitlab.freedesktop.org/xorg/util/cf"
LICENSE="MIT"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS=${PN}

local EPREFIX=${EPREFIX%/}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

echo "#define ManDirectoryRoot ${EPREFIX}/usr/share/man" >> \
  "${ED}"/$(get_libdir)/X11/config/host.def || die
sed -i -e "s|LibDirName *lib$|LibDirName $(get_libdir)|" \
  "${ED}"/$(get_libdir)/X11/config/Imake.tmpl || die "failed libdir sed"
sed -i -e "s|LibDir Concat(ProjectRoot,/lib/X11)|LibDir Concat(ProjectRoot,/$(get_libdir)/X11)|" \
  "${ED}"/$(get_libdir)/X11/config/X11.tmpl || die "failed libdir sed"
sed -i -e "s|\(EtcX11Directory \)\(/etc/X11$\)|\1${EPREFIX}\2|" \
  "${ED}"/$(get_libdir)/X11/config/X11.tmpl || die "failed etcx11dir sed"
sed -i -e "/#  define Solaris64bitSubdir/d" \
  "${ED}"/$(get_libdir)/X11/config/sun.cf || die
sed -i -e 's/-DNOSTDHDRS//g' \
  "${ED}"/$(get_libdir)/X11/config/sun.cf || die

sed -r -i -e "s|LibDirName[[:space:]]+lib.*$|LibDirName $(get_libdir)|" \
  "${ED}"/$(get_libdir)/X11/config/linux.cf || die "failed libdir sed"
sed -r -i -e "s|SystemUsrLibDir[[:space:]]+/usr/lib.*$|SystemUsrLibDir /$(get_libdir)|" \
  "${ED}"/$(get_libdir)/X11/config/linux.cf || die "failed libdir sed"
sed -r -i -e "s|TkLibDir[[:space:]]+/usr/lib.*$|TkLibDir /$(get_libdir)|" \
  "${ED}"/$(get_libdir)/X11/config/linux.cf || die "failed libdir sed"

printf %s\\n "Install: ${PROGS}"
