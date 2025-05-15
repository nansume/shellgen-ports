# 2021-2023

local DPREFIX=${DPREFIX#/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

case ${XPN} in
  'libuuid')
  ;;
  *) return;;
esac

# bug: required - nilfs-utils
mkdir -pm '0755' ${DPREFIX}/include/uuid/
mv -vn ${WORKDIR}/libuuid/src/"uuid.h" ${DPREFIX}/include/uuid/
