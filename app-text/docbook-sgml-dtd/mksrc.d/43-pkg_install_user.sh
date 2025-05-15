#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip +x32

DESCRIPTION="Docbook SGML DTD ${PV}"
HOMEPAGE="https://docbook.org/sgml/"
LICENSE="docbook"
DATAFILES="*.dcl *.dtd *.mod *.xml"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/etc/sgml/ "${ED}"/usr/share/sgml/docbook/sgml-dtd-${PV}/

mv -n ${DATAFILES} "${ED}"/usr/share/sgml/docbook/sgml-dtd-${PV}/

mv -n docbook.cat "${ED}"/usr/share/sgml/docbook/sgml-dtd-${PV}/catalog

cat > sgml-docbook-${PV}.cat <<-EOF
CATALOG "/usr/share/sgml/docbook/sgml-dtd-${PV}/catalog"
CATALOG "/etc/sgml/sgml-docbook.cat"
EOF

mv -n sgml-docbook-${PV}.cat "${ED}"/etc/sgml/

printf %s\\n "Install: ${DATAFILES} ${ED}/usr/share/sgml/docbook/sgml-dtd-${PV}/"
