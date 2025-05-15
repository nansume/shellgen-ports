#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 16:00 UTC - fix: near to compat-posix, no-posix: local VAR

local IFS="$(printf '\n\t')"; IFS=${IFS%?}; local LIST; local F

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

#use 'strip' || return 0
use 'upx' && spkg-dep "app-arch/upx"

test -n "${BUILDLIST}" && return

LIST="$(globstar bin/)${IFS}$(globstar ${LIB_DIR}/)${IFS}$(globstar lib/)${IFS}$(globstar sbin/)"
LIST="${LIST:+${LIST}${IFS}}$(globstar opt/)${IFS}$(globstar usr/libexec/)"

for F in ${LIST}; do
  case ${F} in *"/i386-pc/"*) continue;; esac  # skip: lib*/grub/i386-pc/*.mod [elf32-i386]
  testelf ${F} &&
  case ${F} in
    *'.a'|*'.o')
      use 'strip' && strip --strip-unneeded ${F} && printf %s\\n "strip --strip-unneeded ${F}"
      use 'upx' && upx --best "${F}"
    ;;
    *)
      # bug: in static libraries and object files remove global symbols - no safe for static lib, object files
      # https://www.technovelty.org/linux/stripping-shared-libraries.html
      use 'strip' && strip --verbose --strip-all ${F}
      use 'upx' && upx --best "${F}"
    ;;
  esac
done
#strip --strip-all bin/${PN} ${DPREFIX#/}/libexec/*/* ${LIB_DIR}/lib*.so.${PV} ${LIB_DIR}/lib${PN}.so.?.*

#shopt -s globstar extglob
#GLOBIGNORE='!(*/usr/bin/*_*|?(*/)?(*/)?(*/)?(*/)*.so?(.*))
