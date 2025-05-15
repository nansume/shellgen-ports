ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

mkdir -pm '0755' ${ED}/bin/

mv -n ${PN} apis xlisten "${ED}"/bin/ &&

printf %s\\n "mv -vn ${PN} apis xlisten ${ED}/bin/"
