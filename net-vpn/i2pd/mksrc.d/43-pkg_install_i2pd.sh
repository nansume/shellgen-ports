# 2021-2022

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

umask u=rwx,g=rx,o=rx
mkdir -pm '0755' ${INSTALL_DIR}/sbin/ ${INSTALL_DIR}/var/lib/${PN}/

cp -nl ${PN} "${INSTALL_DIR}"/sbin/
cp -ulr contrib/certificates/ ${INSTALL_DIR}/var/lib/${PN}/
