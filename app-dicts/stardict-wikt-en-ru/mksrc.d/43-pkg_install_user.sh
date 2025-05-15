#!/bin/sh
# -static -static-libs -shared -upx +gzip -patch -doc -xstub -diet -musl -stest -strip -noarch

DESCRIPTION="Stardict Dictionary Wiktionary English-Russian"
HOMEPAGE="https://sourceforge.net/projects/xdxf/files/"
LICENSE="GPL-2"
IUSE="+gzip"
DATAFILES="*.dict.dz* *.idx* *.ifo"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

# || ( app-text/stardict app-text/sdcv app-text/goldendict )
# gzip? ( app-arch/gzip app-text/dictd )

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

for F in *.idx *.dict* *.ifo; do
  mv -n "${F}" "${F// /-}"
done

if use 'gzip'; then
  #for F in *.idx; do
  #  test -f ${F} && gzip -6 ${F}
  #done
  for F in *.dict; do
    test -f "${F}" && dictzip ${F}
  done
fi

mkdir -pm 0755 "${ED}"/usr/share/stardict/dic/
mv -n ${DATAFILES} "${ED}"/usr/share/stardict/dic/ &&
printf %s\\n "mv -n ${DATAFILES} ${ED}/usr/share/stardict/dic/"
