#!/bin/sh

local WORKDIR=${WORKDIR}; local PKGNAME=${PKGNAME}; local SYMVER='2.1.0'; local RMLIST

test "X${USER}" != 'Xroot' || return 0

export WORKDIR PKGNAME

cd "${DISTSOURCE}/" || exit

: gen-variables
pkg-unpack PKGNAME=${PKGNAME} && USE_BUILD_ROOT='0'

cd "${WORKDIR}/" || exit

src-patch

cp -nul "src/headers/${PN}.h" ${DPREFIX}/include/ &&
printf %s\\n "cp -nul src/headers/${PN}.h -> ${DPREFIX}/include/"

>>doc/gpm.info && printf %s\\n "create or skip: >>doc/gpm.info"

printf %s\\n "Configure directory: PWD='${PWD}'... ok"

./autogen.sh &&
./configure \
  --prefix=${SPREFIX} \
  --bindir=${SPREFIX%/}/bin \
  --sbindir=${SPREFIX%/}/sbin \
  --libdir=${SPREFIX%/}/${LIB_DIR} \
  --includedir=${INCDIR} \
  --libexecdir=${DPREFIX}/libexec \
  --datarootdir=${DPREFIX}/share \
  --host=${CHOST} \
  --build=${CHOST} \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_with 'ncurses' curses) || exit

make || exit
make DESTDIR='/install' install-strip || exit

cd ${INSTALL_DIR}/${LIB_DIR}/ || exit

# fix: not found <gpm> (lib)
ln -sf "lib${PN}.so.${SYMVER}" "lib${PN}.so"
ln -sf "lib${PN}.so.${SYMVER}" "lib${PN}.so.1"

cd "${INSTALL_DIR}/" || exit

post-inst-perm

RMLIST="$(pkg-rmlist)" pkg-rm

post-rm
pkg-rm-empty
pre-perm
