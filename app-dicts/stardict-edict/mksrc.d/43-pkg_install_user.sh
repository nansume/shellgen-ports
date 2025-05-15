#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl +stest +strip +x32

DESCRIPTION="Collection of dicts for stardict."
HOMEPAGE="http://stardict.sourceforge.net/Dictionaries_ja.php"
DATAFILES="edict.dict.dz edict.idx edict.ifo"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
