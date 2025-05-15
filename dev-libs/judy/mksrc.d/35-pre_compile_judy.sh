test "X${USER}" != 'Xroot' || return 0

sed -i 's/^SUBDIRS = src tool doc test/SUBDIRS = src tool/' Makefile