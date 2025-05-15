# 2021

test "x${USER}" != 'xroot' || return 0

cd ${INSTALL_DIR}/

# bug fix: libnsl not found
ln -s "libnsl"-${PV}".so" ${LIB_DIR}/"libnsl.so".2
