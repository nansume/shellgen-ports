# 2022-2025

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

>> doc/man/libhid-detach-device.1
