DESCRIPTION="transmission web control"
HOMEPAGE="https://github.com/ronggang/transmission-web-control/"
LICENSE="MIT"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/usr/share/transmission/web/
: mv -n "${ED}"/usr/share/transmission/web/index.html "${ED}"/usr/share/transmission/web/index.new.html
mv -n src/* -t "${ED}"/usr/share/transmission/web/ &&
printf %s\\n "Install: ${PN}"
