local X

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${ED}/ || return

for X in "$(get_libdir)/pkgconfig/"lib*.pc; do
  test -e "${X}" || break
  sed -i '4,5s|^includedir=.*$|includedir=/usr/include/sys|;t' ${X}
done
