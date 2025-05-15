# -static -static-libs -shared -lfs -upx +patch -doc -man -xstub -diet -musl -stest -strip +noarch

DESCRIPTION="GNU utility to convert program --help output to a man page"
HOMEPAGE="https://www.gnu.org/software/help2man/ https://salsa.debian.org/bod/help2man"
LICENSE="GPL-3+ | +nls ( FSFAP for bindtextdomain.c )"
IUSE="-nls"
# bug #385753
DOCS="debian/changelog NEWS README THANKS"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export BUILD_DIR DOCS

test "X${USER}" != 'Xroot' || return 0
cd ${BUILD_DIR}/ || return

sed 's/-shared/-bundle/' -i Makefile.in || die

# Disable gettext requirement as the release includes the gmo files, bug #555018
MYCONF="${MYCONF}
 ac_cv_path_MSGFMT=$(type -P false)
"
