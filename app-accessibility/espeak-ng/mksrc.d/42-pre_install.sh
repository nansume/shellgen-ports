#!/bin/sh
# -static -static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Software speech synthesizer for English, and some other languages"
HOMEPAGE="https://github.com/espeak-ng/espeak-ng"
LICENSE="GPL-3+ unicode"
IUSE="-static -static-libs -shared -diet (+musl) +stest (-test) +strip"
IUSE="${IUSE} -rpath +async +klatt +l10n_ru -l10n_zh -man +mbrola +sound -doc -xstub"
ED=${INSTALL_DIR}

# testing (architecture-independent): --prefix=${EPREFIX} -> --prefix=${DPREFIX}
# configure
#MYCONF=$(printf ${MYCONF} | sed "s/--prefix=${EPREFIX} /--prefix=${DPREFIX} /")

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return
cd "${WORKDIR}/"

MAKEFLAGS="V=0 DATADIR=/usr/share VIMDIR=/usr/share/vim/vimfiles"

make ${MAKEFLAGS} DESTDIR=${ED} install || die "make install... error"
