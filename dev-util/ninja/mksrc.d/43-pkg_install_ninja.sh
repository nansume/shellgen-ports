test "x${USER}" != 'xroot' || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

test -e "${WORKDIR}/${PN}" &&

mkdir -pm 0755 "bin/" &&
cp -nl ${WORKDIR}/${PN} "bin/" &&

printf %s\\n "cp -nl ${WORKDIR}/${PN} --> bin/${PN}"
