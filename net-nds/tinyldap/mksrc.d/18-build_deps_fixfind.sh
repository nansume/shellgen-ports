test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

# FIX: tinyldap.c:24:10: fatal error: wait.h: No such file or directory
ln -v -s /opt/diet/include/fcntl.h /opt/diet/include/sys/
ln -v -s /opt/diet/include/sys/wait.h /opt/diet/include/
ln -v -s /opt/diet/include/unistd.h /opt/diet/include/linux/
printf %s\\n "ln -s /opt/diet/include/fcntl.h /opt/diet/include/sys/"