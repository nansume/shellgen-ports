# -static +static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="ELF object file access library (deprecated)"
HOMEPAGE="https://directory.fsf.org/wiki/Libelf"
LICENSE="LGPL-2+"
DOCS="ChangeLog README"
IUSE="-debug -nls"
INSTALL_OPTS="install install-compat"

test "X${USER}" != 'Xroot' || return 0

export mr_cv_target_elf="yes"

MYCONF=$(mapsetre '--datarootdir=*' '' ${MYCONF})

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }instroot=${INSTALL_DIR}"

test -x "/bin/perl" && autoreconf --install