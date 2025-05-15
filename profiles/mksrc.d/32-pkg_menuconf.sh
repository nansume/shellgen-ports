#!/bin/sh
# Copyright (C) 2021-2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 08:00 UTC - fix: near to compat-posix

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || exit
cd "${WORKDIR}/"

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

# required: Cdialog
#[[ -f Makefile.gui ]] && { . testxpath dialog && make -f Makefile.gui; return;}  # no work
test -f 'Makefile.gui' && { test -x '/bin/dialog' && make -f 'Makefile.gui'; return;}

test -f '.config' || return 0

make oldconfig >> '/var/log/mkconfig.log' || exit

#make menuconfig
#make config
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'

#declare -p > /var/log/mkbuild.env
