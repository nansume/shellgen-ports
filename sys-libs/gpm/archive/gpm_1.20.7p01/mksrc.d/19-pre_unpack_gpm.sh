# 2021-2023

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "x${USER}" != 'xroot' && return

#trap
#trap chown root:root ${DPREFIX}/include/; trap - ERR' ERR
chown ${BUILD_USER:?}:${BUILD_USER} "${DPREFIX}/include/"
