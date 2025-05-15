test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "x${USER}" != 'xroot' && return

chown -R ${BUILD_USER}:${BUILD_USER} "${DPREFIX}/include/"
