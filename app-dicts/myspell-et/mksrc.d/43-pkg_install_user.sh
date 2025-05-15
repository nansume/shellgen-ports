#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

# http://data.gpo.zugaina.org/gentoo/app-dicts/myspell-et/myspell-et-20030606.ebuild
# https://gitweb.gentoo.org/repo/gentoo.git/plain/eclass/myspell-r2.eclass

IFS="$(printf '\n\t') "
DESCRIPTION="Estonian dictionaries for myspell/hunspell"
HOMEPAGE="http://www.meso.ee/~jjpp/speller/"
LICENSE="LGPL-3"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

MYSPELL_DICT="latin-9/et_EE.aff latin-9/et_EE.dic"
MYSPELL_THES=""
MYSPELL_HYPH="hyph_et_EE.dic"

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# naming handling to be inline with others
mv -n hyph_et.dic -T hyph_et_EE.dic || die

mkdir -pm 0755 -- "${ED}"/usr/share/hunspell/ "${ED}"/usr/share/mythes/
mkdir -pm 0755 -- "${ED}"/usr/share/hyphen/ "${ED}"/usr/share/myspell/

mv -v -n ${MYSPELL_DICT} -t "${ED}"/usr/share/hunspell/
mv -v -n ${MYSPELL_HYPH} -t "${ED}"/usr/share/hyphen/

cd "${ED}"/usr/share/myspell/

ln -v -s ../hunspell/* "${ED}"/usr/share/myspell/
ln -v -s ../hyphen/* "${ED}"/usr/share/myspell/

cd ${BUILD_DIR}/ || return
printf %s\\n "Install: ${PN}"
