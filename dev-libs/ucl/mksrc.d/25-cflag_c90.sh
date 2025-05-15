# [ucl] ACC conformance test failure
#  https://bugs.archlinux.org/task/49287
CPPFLAGS="${CPPFLAGS:+${CPPFLAGS} }-std=c90 -fPIC"

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0
# ok - color: green
printf " \e[1;32m+\e[m ${SCNAME##*/}... append flags\n"
