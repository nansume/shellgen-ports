test "x${USER}" != 'xroot' || return 0

cd ${WORKDIR}/ && make strip
