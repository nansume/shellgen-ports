#!/bin/sh
# +static +static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="NetBSD's portable make"
HOMEPAGE="http://www.crufty.net/help/sjg/bmake.html"
LICENSE="BSD"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}
PROGS=${PN}

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 "${ED}"/bin/
mv -n ${PROGS} "${ED}"/bin/ &&
printf %s\\n "Install: ${PROGS} bin/"

FORCE_BSD_MK=1 SYS_MK_DIR=. \
sh mk/install-mk -v -m 644 "${ED}"/usr/share/mk/${PN} || die "failed to install mk files"
