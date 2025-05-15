inherit install-functions

export PN PV ED

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

dobin $(cat ../package/commands)
dodoc CHANGES ../package/README TODO
doman "${WORKDIR}"/${PN}-man/*.8
