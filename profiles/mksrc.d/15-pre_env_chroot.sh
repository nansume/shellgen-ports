test "${BUILD_CHROOT:=0}" -ne '0' || return 0

PDIR="/"
DISTSOURCE="/sources"
DISTDIR="/usr/distfiles"
INSTALL_OPTS="install"
INSTALL_DIR="/install"
S="/${SRC_DIR}"
SDIR="/${SRC_DIR}"

printf %s\\n "XABI='${XABI}'" "DPREFIX='${DPREFIX}'" "PWD='${PWD}'" "PDIR='${PDIR}'" "P='${P}'" "SN='${SN}'"
printf %s\\n "PN='${PN}'" "PORTS_DIR='${PORTS_DIR}'" "DISTSOURCE='${DISTSOURCE}'" "DISTDIR='${DISTDIR}'"
printf %s\\n "INSTALL_DIR='${INSTALL_DIR}'" "S='${S}'" "SDIR='${SDIR}'" "XPWD='${XPWD}'"
