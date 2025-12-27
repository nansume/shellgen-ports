# 2021-2022

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

umask u=rwx,g=rx,o=rx
mkdir -pm '0755' ${INSTALL_DIR}/bin/ ${INSTALL_DIR}/etc/

mkdir -pm '0755' ${INSTALL_DIR}/usr/share/man/man1/ ${INSTALL_DIR}/usr/share/man/man2/
mkdir -pm '0755' ${INSTALL_DIR}/usr/share/man/man3/ ${INSTALL_DIR}/usr/share/man/man4/
mkdir -pm '0755' ${INSTALL_DIR}/usr/share/man/man5/ ${INSTALL_DIR}/usr/share/man/man6/
mkdir -pm '0755' ${INSTALL_DIR}/usr/share/man/man7/ ${INSTALL_DIR}/usr/share/man/man8/

mkdir -pm '0755' ${INSTALL_DIR}/usr/include/et/ ${INSTALL_DIR}/usr/include/ss/
mkdir -pm '0755' ${INSTALL_DIR}/usr/include/e2p/ ${INSTALL_DIR}/usr/include/ext2fs/

mkdir -pm '0755' ${INSTALL_DIR}/usr/share/et/ ${INSTALL_DIR}/usr/share/ss/
mkdir -pm '0755' ${INSTALL_DIR}/usr/share/e2p/ ${INSTALL_DIR}/usr/share/ext2fs/

mkdir -pm '0755' ${INSTALL_DIR}/${LIB_DIR}/pkgconfig/

#cd ${INSTALL_DIR}/
#mv -vn etc/mke2fs.conf etc/mke2fs.conf.new
