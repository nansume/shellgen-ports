test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

rm -- "/${LIB_DIR}/libstdc++.la"