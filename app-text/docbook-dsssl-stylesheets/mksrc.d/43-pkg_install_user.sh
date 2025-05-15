#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip +x32

DESCRIPTION="DSSSL Stylesheets for DocBook"
HOMEPAGE="https://github.com/docbook/wiki/wiki"
LICENSE="MIT"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local d catdir="usr/share/sgml/docbook/dsssl-stylesheets-${PV}"

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/bin/ "${ED}"/etc/sgml/ "${ED}"/${catdir}/

mv -n bin/collateindex.pl "${ED}"/bin/
mv -n catalog VERSION "${ED}"/${catdir}/

mkdir -m 0755 "${ED}"/${catdir}/common/
mv -n common/*.dsl common/*.ent "${ED}"/${catdir}/common/

mkdir -m 0755 "${ED}"/${catdir}/images/
mv -n images/*.gif "${ED}"/${catdir}/images/

for d in html lib olink print; do
  mkdir -m 0755 "${ED}"/${catdir}/${d}/
  mv -n "${d}"/*.dsl "${ED}"/${catdir}/${d}/
done
for d in dbdsssl html imagelib olink; do
  mkdir -pm 0755 "${ED}"/${catdir}/dtds/${d}/
  mv -n "dtds/${d}"/*.dtd "${ED}"/${catdir}/dtds/${d}/
done
#mkdir -pm 0755 "${ED}"/${catdir}/dtds/html/
mv -n dtds/html/*.dcl dtds/html/*.gml "${ED}"/${catdir}/dtds/html/

cat > dsssl-docbook-stylesheets.cat <<-EOF
CATALOG "/usr/share/sgml/docbook/dsssl-stylesheets-${PV}/catalog"
EOF

mv -n dsssl-docbook-stylesheets.cat "${ED}"/etc/sgml/

printf %s\\n "Install: dsssl-docbook-stylesheets.cat ${ED}/etc/sgml/"
