inherit install-functions

DOCS="CHANGES README TODO VERSION"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV BUILD_DIR ED DOCS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

dobin ${PN}dump ${PN}get ${PN}make ${PN}make-12 ${PN}make-sv ${PN}stats ${PN}test

# ok so ... first off, some automakes fail at finding
# cdb.a, so install that now
dolib.a *.a
# then do this pretty little symlinking to solve the somewhat
# cosmetic library issue at hand
dosym ${PN}.a /$(get_libdir)/lib${PN}.a

# uint32.h needs installation too, otherwise compiles depending
# on it will fail
insinto /usr/include/${PN}
doins ${PN}*.h alloc.h buffer.h uint32.h

einstalldocs
