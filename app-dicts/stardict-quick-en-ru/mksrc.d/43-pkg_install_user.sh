#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip -noarch

DESCRIPTION="Quick but still useful English to Russian dictionary"
HOMEPAGE="http://download.huzheng.org/Quick/"
LICENSE="GPL-2"
DATAFILES="*.dict.dz *.idx *.ifo"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
DICT_PREFIX=""
DICT_SUFFIX="quick_eng-rus"

# || ( app-text/stardict app-text/sdcv app-text/goldendict )
# gzip? ( app-arch/gzip app-text/dictd )

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 -- "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} -t "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
