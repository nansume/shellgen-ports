# 2021-2023

local PN=${XPN}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

test "x${XPN}" = 'xlosetup' || return 0

ln -s ${PN##*-} sbin/${PN}
