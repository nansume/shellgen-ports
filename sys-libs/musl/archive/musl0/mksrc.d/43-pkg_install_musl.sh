local ARCH='x32'; local _LIB_DIR='lib'

test "X${USER}" != 'Xroot' || return 0

cd "${INSTALL_DIR}/"

test -x 'bin/musl-gcc' && sed -i 's/-musl-gcc/-gcc/' bin/musl-gcc

ln -sf 'libc.so' "${LIB_DIR}/ld-musl-${ARCH}.so.1" &&
printf %s\\n "ln -sf libc.so -> ${LIB_DIR}/ld-musl-${ARCH}.so.1"

ln -s "../${LIB_DIR}/ld-musl-${ARCH}.so.1" 'bin/ldd' &&
printf %s\\n "ln -s ../${LIB_DIR}/ld-musl-${ARCH}.so.1 -> bin/ldd"
