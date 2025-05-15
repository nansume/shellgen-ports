# 2022

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.ac
