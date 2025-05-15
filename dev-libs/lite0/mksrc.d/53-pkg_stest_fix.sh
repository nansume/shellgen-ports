#!/bin/sh

export ED

ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd "${ED}/" || die "install dir: not found... error"

rm -- bench.log

sed -e 's|${prefix}|/usr|' -i $(get_libdir)/pkgconfig/*.pc || : die
