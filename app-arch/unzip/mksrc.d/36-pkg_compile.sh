#!/bin/sh

PV="6.0"
ED=${INSTALL_DIR}

local MAKEFLAGS=

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

test "X${USER}" != 'Xroot' || return 0

export LOCAL_UNZIP=" -DNO_LCHMOD"

runverb ${IONICE_COMM} \
make CC="gcc" -f "unix/Makefile" $(usex 'x86' linux_asm linux_noasm) || exit

sed -i "s:^BINDIR = .*:BINDIR = ${ED}/bin:" Makefile