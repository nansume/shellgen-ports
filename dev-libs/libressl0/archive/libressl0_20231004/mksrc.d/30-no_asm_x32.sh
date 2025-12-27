test "X${ABI}" != 'Xx32' && return

# support x32
MYCONF="${MYCONF:+${MYCONF}${NL}}--disable-asm"
