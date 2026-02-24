#!/bin/sh

ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

mv -n "${ED}"/share/pkgconfig -t "${ED}"/usr/share/
