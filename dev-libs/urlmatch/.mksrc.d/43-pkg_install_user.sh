ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${ED}" || return 0
cd "${ED}/"

mkdir -m 0755 "usr/include/" &&
mv -n lib "$(get_libdir)" &&
mv -n include/* "usr/include/" &&

printf %s\\n "fix: libdir include"
