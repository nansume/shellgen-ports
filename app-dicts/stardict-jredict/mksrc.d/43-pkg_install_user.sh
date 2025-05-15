#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

DESCRIPTION="JR-EDICT electronic Japanese-Russian dictionary"
HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_ja.php"
HOMEPAGE="http://download.huzheng.org/ja/"
LICENSE="GPL-2"  # StarDict2, developed by Hu Zheng under license GPL-2
DATAFILES="*.dict.dz *.idx *.ifo"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 -- "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} -t "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
