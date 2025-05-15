# +static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Spell checker, morphological analyzer library and command-line tool"
HOMEPAGE="https://hunspell.github.io/"
LICENSE="|| ( MPL-1.1 GPL-2+ LGPL-2.1+ )"
IUSE="+ncurses -nls +readline +static-libs"
BUILD_DIR=${WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

autoreconf --install
