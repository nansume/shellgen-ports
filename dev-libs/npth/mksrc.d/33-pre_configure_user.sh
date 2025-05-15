cd ${WORKDIR}/

test "X${USER}" != 'Xroot' || return 0

autoreconf --install
