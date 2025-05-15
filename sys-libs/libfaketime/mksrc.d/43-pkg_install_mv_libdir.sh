# 2021-2024

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${ED}" || return 0
cd "${ED}/"

mv -vn "lib/${PN#lib}/" "${LIB_DIR}"
