#!/bin/sh
# 2021
# Date: 2023-10-15 08:00 UTC - fix: near to compat-posix

test "x${USER}" != 'xroot' && {
  cd ${WORKDIR}/

  for ARG in "programs" "lib"; do
   make -C ${ARG} PREFIX="" LIBDIR="/${LIB_DIR}" INCLUDEDIR="${DPREFIX}/include" DESTDIR="${INSTALL_DIR}" install
  done

  cd ${INSTALL_DIR}/ || exit
}
