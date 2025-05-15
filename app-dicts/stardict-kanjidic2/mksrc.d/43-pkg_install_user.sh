#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch


DESCRIPTION="Stardict Dictionary Japanese-English - Kanjidic2 (Kanji dictionary)"
HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_ja.php"
HOMEPAGE="http://download.huzheng.org/ja/"
LICENSE="GDLS"  # it what such?
LICENSE="The EDRDG Licence"  # jmdict under license: CC-BY-SA-4.0
DATAFILES="*.dict.dz *.idx *.ifo"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 -- "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} -t "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
