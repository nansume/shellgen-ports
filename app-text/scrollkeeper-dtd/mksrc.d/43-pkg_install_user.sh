#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="DTD from the Scrollkeeper package"
HOMEPAGE="https://scrollkeeper.sourceforge.net/"
SRC_URI="https://scrollkeeper.sourceforge.net/dtds/scrollkeeper-omf-1.0/${DTD_FILE}"
LICENSE="FDL-1.1"
FILESDIR=${DISTSOURCE}
DTD_FILE="scrollkeeper-omf.dtd"
DATAFILES="${FILESDIR}/${DTD_FILE}"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
EROOT=${ED}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/etc/xml/ "${ED}"/usr/share/xml/scrollkeeper/dtds/
cp -n -L ${DATAFILES} -t "${ED}"/usr/share/xml/scrollkeeper/dtds/ &&

printf %s\\n "Installing catalog..."

# Install regular DOCTYPE catalog entry
xmlcatalog --noout --add "public" \
        "-//OMF//DTD Scrollkeeper OMF Variant V1.0//EN" \
        "${EROOT}"/usr/share/xml/scrollkeeper/dtds/${DTD_FILE} \
        "${EROOT}"/etc/xml/catalog

# Install catalog entry for calls like: xmllint --dtdvalid URL ...
xmlcatalog --noout --add "system" \
        "${SRC_URI}" \
        "${EROOT}"/usr/share/xml/scrollkeeper/dtds/${DTD_FILE} \
        "${EROOT}"/etc/xml/catalog

# Remove all sk-dtd from the cache
printf %s\\n "Cleaning catalog..."

xmlcatalog --noout --del \
        "${EROOT}"/usr/share/xml/scrollkeeper/dtds/${DTD_FILE} \
        "${EROOT}"/etc/xml/catalog

test -s "${EROOT}/etc/xml/catalog" || rm -v -- "${EROOT}"/etc/xml/catalog

printf %s\\n "Install: ${DATAFILES} /usr/share/xml/scrollkeeper/dtds/"
