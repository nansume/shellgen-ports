# 2021-2022
test "x${USER}" != 'xroot' || return 0

mkdir -pm '0755' ${INSTALL_DIR}/bin/
#cp -vnul ${WORKDIR}/${PN} ${INSTALL_DIR}/bin/
cp -vnul ${WORKDIR}/${PKGNAME} "${INSTALL_DIR}"/bin/ &&
printf %s\\n "cp -vnul ${WORKDIR}/${PKGNAME} ${INSTALL_DIR}/bin/"
