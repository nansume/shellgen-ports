# 2021-2023

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "x${USER}" != 'xroot' && return

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

chown -R root:root "${DPREFIX}/include/"
#chown -v root:network etc/{gai,host,nsswitch,resolv}.conf etc/hosts
