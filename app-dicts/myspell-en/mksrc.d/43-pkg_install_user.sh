#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

# http://data.gpo.zugaina.org/gentoo/app-dicts/myspell-en/myspell-en-20250401.ebuild
# https://gitweb.gentoo.org/repo/gentoo.git/plain/eclass/myspell-r2.eclass

IFS="$(printf '\n\t') "
DESCRIPTION="English dictionaries for myspell/hunspell"
HOMEPAGE="https://extensions.libreoffice.org/extensions/english-dictionaries"
LICENSE="BSD MIT LGPL-3+"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PV=${PV%.lo}  # FIX: wrong name: myspell-en_20250401.lo_all.clz

MYSPELL_DICT="en_US.aff en_US.dic"
MYSPELL_THES="th_en_US_v2.dat th_en_US_v2.idx"
MYSPELL_HYPH="hyph_en_US.dic"

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 -- "${ED}"/usr/share/hunspell/ "${ED}"/usr/share/mythes/
mkdir -pm 0755 -- "${ED}"/usr/share/hyphen/ "${ED}"/usr/share/myspell/

mv -v -n ${MYSPELL_DICT} -t "${ED}"/usr/share/hunspell/
mv -v -n ${MYSPELL_THES} -t "${ED}"/usr/share/mythes/
mv -v -n ${MYSPELL_HYPH} -t "${ED}"/usr/share/hyphen/

cd "${ED}"/usr/share/myspell/

ln -v -s ../hunspell/* "${ED}"/usr/share/myspell/
ln -v -s ../mythes/* "${ED}"/usr/share/myspell/
ln -v -s ../hyphen/* "${ED}"/usr/share/myspell/

cd ${BUILD_DIR}/ || return
printf %s\\n "Install: ${PN}"
