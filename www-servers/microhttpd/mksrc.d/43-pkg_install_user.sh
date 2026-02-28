ED=${ED:-$INSTALL_DIR}

test "x${USER}" != 'xroot' || return 0

mv "${ED}"/bin/${PN} "${ED}"/bin/${PN}_
mv "${ED}"/bin/${PN}_/${PN}_* "${ED}"/bin/${PN}
rmdir "${ED}"/bin/${PN}_/

printf %s\\n "Install: ${PN}... ok"
