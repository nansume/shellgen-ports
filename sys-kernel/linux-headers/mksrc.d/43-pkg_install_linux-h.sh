# 2021-2022

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

make 'mrproper'
make INSTALL_HDR_PATH=${INSTALL_DIR}${DPREFIX} 'headers_install'

#mkdir -pm 0750 ${INSTALL_DIR}/${DPREFIX#/}/
#cp -ulr dest/include/ ${INSTALL_DIR}/${DPREFIX#/}/include/
