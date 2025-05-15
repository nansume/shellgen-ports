#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

DESCRIPTION="Stardict Dictionary English-Japanese (jmdict)"
HOMEPAGE="http://www.edrdg.org/edrdg/newlic.html http://download.huzheng.org/ja/"
LICENSE="GDLS"  # jmdict under license: CC-BY-SA-4.0
LICENSE="The EDRDG Licence"  # jmdict under license: CC-BY-SA-4.0
DATAFILES="*.dict.dz *.idx *.ifo"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
DICT_PREFIX="jmdict-"

# || ( app-text/stardict app-text/sdcv app-text/goldendict )
# gzip? ( app-arch/gzip app-text/dictd )

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 -- "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} -t "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
