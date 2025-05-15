export PN PV ED BUILD_DIR

DOCS="ANNOUNCEMENT NEWS README ChangeLog TODO VERSION"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# Install .so into LDPATH
if use 'shared'; then
  mv "${ED}"/$(get_libdir)/${PN}/libbg.so.2.0.0 "${ED}"/$(get_libdir)/ || : die
  dosym libbg.so.2.0.0 /$(get_libdir)/libbg.so.2
  dosym libbg.so.2.0.0 /$(get_libdir)/libbg.so
  dosym ../libbg.so.2.0.0 /$(get_libdir)/${PN}/libbg.so.2.0.0
  rm "${ED}"/$(get_libdir)/${PN}/libbg.la || die
fi
if use 'static-libs'; then
  mv "${ED}"/$(get_libdir)/${PN}/lib*.a "${ED}"/$(get_libdir)/ || : die
  dosym ../libbg-cli.a       /$(get_libdir)/${PN}/libbg-cli.a
  dosym ../libbg.a           /$(get_libdir)/${PN}/libbg.a
  dosym ../libpwcmp-module.a /$(get_libdir)/${PN}/libpwcmp-module.a
  dosym ../libpwcmp.a        /$(get_libdir)/${PN}/libpwcmp.a
  dosym ../libvmailmgr.a     /$(get_libdir)/${PN}/libvmailmgr.a
fi

dodoc ${DOCS}
dodoc -r doc/html/
if use 'doc'; then
  dodoc doc/latex/refman.pdf
fi
