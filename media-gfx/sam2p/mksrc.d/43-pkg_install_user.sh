export ED

PROGS=${PN}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/bin/

dobin ${PROGS} &&

printf %s\\n "Install: mv -n ${PROGS} -t bin/"
