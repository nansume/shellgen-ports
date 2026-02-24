#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

[ "X${USER}" != 'Xroot' ] || return 0

cd ${BUILD_DIR}/ || return

sed -e "/data_files=/ s|/usr/share/${PN}/|${ED}/usr/share/${PN}/|" -i setup.py
