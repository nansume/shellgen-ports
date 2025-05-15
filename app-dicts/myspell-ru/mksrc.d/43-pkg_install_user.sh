#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

# https://gitweb.gentoo.org/repo/gentoo.git/plain/eclass/myspell-r2.eclass

IFS="$(printf '\n\t') "
DESCRIPTION="Russian spellcheck dictionary based on works of AOT group for myspell/hunspell"
HOMEPAGE="https://extensions.libreoffice.org/extensions/russian-dictionary-pack"
LICENSE="LGPL-2.1"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

MYSPELL_DICT="ru_RU.dic ru_RU.aff"
MYSPELL_THES="th_ru_RU_v2.dat th_ru_RU_v2.idx"
MYSPELL_HYPH="hyph_ru_RU.dic"

EXT="extensions"
DICT="russian-dictionary-pack"
MY_PN="dict_pack_ru-aot"
MY_PV="0.4.5"

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mv -n russian-aot.dic -T ru_RU.dic || die
mv -n russian-aot.aff -T ru_RU.aff || die
mv -n ru_th_aot.dat -T th_ru_RU_v2.dat || die
mv -n ru_th_aot.idx -T th_ru_RU_v2.idx || die

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
