test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

: ${INSTALL_DIR:?}

ED=${ED:-$INSTALL_DIR}

mkdir -pm 0755 -- "${ED}"/dev/
mknod -m 0622 "${ED}"/dev/grsec c 1 13 &&

printf %s\\n 'mknod -m 0622 ${ED}/dev/grsec c 1 13' ||
printf %s\\n 'mknod -m 0622 ${ED}/dev/grsec c 1 13... Error'
