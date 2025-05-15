test "x${XPN}" = 'xlosetup' || return 0

MYCONF="${MYCONF:+${MYCONF}${NL}}--disable-pylibmount"
