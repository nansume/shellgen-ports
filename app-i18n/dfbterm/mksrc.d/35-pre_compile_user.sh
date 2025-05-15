#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# FIX: add missing headers for musl libc.
sed -e '/^#include <asm\/types.h>$/a #include <stddef.h>' -i src/dfbtermslist.c
