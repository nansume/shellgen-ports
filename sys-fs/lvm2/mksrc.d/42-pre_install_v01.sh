#!/bin/sh

# BUG: /lib instead /$(get_libdir)
# BUG: no +static-libs, without +static
# TODO: add <mtab> into /etc/, then get: /etc/mtab

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

if use 'static'; then
  [ -f "${ED}/lib/libdevmapper.a" ] && mv -v -n "${ED}"/lib/libdevmapper.a -t "${ED}"/$(get_libdir)/
  if use 'lvm'; then
    mv -v -n "${BUILD_DIR}"/libdaemon/client/libdaemonclient.a -t "${ED}"/$(get_libdir)/
    mv -v -n "${BUILD_DIR}"/daemons/dmeventd/libdevmapper-event.a -t "${ED}"/$(get_libdir)/
  fi
  for PROG in "${ED}"/sbin/*.static; do
    rm -v -f -- ${PROG%.static}
    mv -v -n ${PROG} ${PROG%.static}
  done
  ln -v -f -s dmsetup "${ED}"/sbin/dmstats
else
  rm -v -- "${ED}"/$(get_libdir)/libdevmapper-event.a "${ED}"/$(get_libdir)/liblvm2cmd.a
  rm -v -- "${ED}"/$(get_libdir)/liblvm2app.a "${ED}"/$(get_libdir)/libdevmapper.a
fi

mv -v -n "${ED}"/libexec -t "${ED}"/usr/

[ -d "${ED}/lib" ] && {
  mv -v -n "${ED}"/lib/libdevmapper.so -t "${ED}"/$(get_libdir)/
  rmdir -v -- "${ED}"/lib/
}

printf %s\\n "Install fix: ${PN}"
