CFLAGS="${CFLAGS:+${CFLAGS} }-Wno-narrowing"
CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }-Wno-narrowing"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0
# ok - color: green
printf " \e[1;32m+\e[m ${SCNAME##*/}... append flags\n"

MYCONF="${MYCONF}
 --disable-readline
 --disable-sdl
"
