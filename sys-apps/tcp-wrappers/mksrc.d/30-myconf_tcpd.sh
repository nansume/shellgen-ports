test "x${USER}" != 'xroot' || return 0

MAKEFLAGS="${MAKEFLAGS}
 REAL_DAEMON_DIR="/sbin"
 NETGROUP=$(usex "netgroups" -DNETGROUPS "")
 STYLE="-DPROCESS_OPTIONS"
 LIBS=$(usex "netgroups" -lnsl "")
"
