ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${WORKDIR}/

mkdir -pm '0755' "${ED}"/bin/

mv -n mkbold mkitalic mkbolditalic "${ED}"/bin/
printf %s\\n "mv -n mkbold mkitalic mkbolditalic ${ED}/bin/"
