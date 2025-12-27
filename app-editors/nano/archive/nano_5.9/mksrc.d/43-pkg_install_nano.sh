#!/bin/sh
# 2021

test "x${USER}" != 'xroot' || return 0

mv -n "${DPREFIX#/}/share/${PN}/extra/"* "${DPREFIX#/}/share/${PN}/"
