#export PROGS="loadkeys openvt"

MYCONF="${MYCONF}
 #--enable-optional-progs='${PROGS}'
 --disable-vlock
 --disable-tests
"

if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
  #ln -v -s /opt/diet/include/linux/vt.h /opt/diet/include/sys/
  :
elif test "X${USER}" != 'Xroot' && use 'diet'; then
  sed -e 's|^#include <sys/vt.h>$|#include <linux/vt.h>|' -i src/openvt.c
  # FIX: for diet libc
  sed -e "s|RESIZECONS_PROGS=yes|RESIZECONS_PROGS=no|" -i configure
fi
