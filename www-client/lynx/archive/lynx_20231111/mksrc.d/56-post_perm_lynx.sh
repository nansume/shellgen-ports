# 2021-2023

local F

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

cd ${INSTALL_DIR}/

for F in "etc/"${PN}".cfg"?*; do
  test -f "${F}" && mv -vf ${F} "etc/"${PN}".cfg"
done

test -f "etc/${PN}.cfg" || return 0

chown -h root:network "etc/"${PN}".cfg"
