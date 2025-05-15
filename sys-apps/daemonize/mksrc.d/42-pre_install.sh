BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS=${PN}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/sbin/
mv -n ${PROGS} -t "${ED}"/sbin/ &&
printf %s\\n "Install: ${PROGS} bin/"
