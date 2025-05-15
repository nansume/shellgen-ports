inherit install-functions

DOCS="ANNOUNCEMENT ChangeLog NEWS README TODO VERSION ${PN}.run ${PN}-log.run"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV ED DOCS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

emake install_prefix=${ED} install
einstalldocs
