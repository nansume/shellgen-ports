#!/bin/sh

{ test "X${USER}" != 'Xroot' ;} || return 0

# FIX: Error: ZIP does not support timestamps before 1980

use 'fixdate1980' || return 0

printf %s\\n "fixdate1980 - DIR='${BUILD_DIR}'"

find "${BUILD_DIR:?}/" -type f -exec touch -ch -d "1980-01-01 00:00:01" {} \; || exit
