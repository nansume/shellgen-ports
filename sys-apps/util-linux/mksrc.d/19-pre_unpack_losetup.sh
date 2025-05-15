# 2021-2023

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "x${USER}" != 'xroot' && return

test "x${XPN}" = 'xlosetup' && return

cd ${DISTSOURCE}/ || exit

rm -- *'.diff.'*
