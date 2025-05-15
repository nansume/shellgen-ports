test "x${USER}" != 'xroot' || return 0

cd ${WORKDIR}/

sed -i 's/FLAGS =/FLAGS +=/' Makefile
