#!/bin/sh

test "X${USER}" != 'Xroot' || return 0

ldd ${QMAKE}
${QMAKE} --help
