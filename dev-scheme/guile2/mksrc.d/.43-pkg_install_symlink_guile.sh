# 2021

test "x${USER}" != 'xroot' || return 0

ln -s "${PN}-${PV%${PV#???}}.pc" "${PKG_CONFIG_LIBDIR}/${PN}-2.0.pc"
