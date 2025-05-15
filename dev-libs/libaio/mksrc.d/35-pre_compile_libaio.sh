test "X${USER}" != 'Xroot' || return 0

#filter-flags -no-pie
CFLAGS=$(printf "${CFLAGS} " | sed 's/-no-pie //;s/ $//')
