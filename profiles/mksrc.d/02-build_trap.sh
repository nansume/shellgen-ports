#!/bin/sh
# Copyright (C) 2016-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html

test -n "${BASH_VERSION}" &&

trap '
  { : set -o "xtrace";} >/dev/null 2>&1
  shopt -u 'globstar' 'dotglob' 'nullglob' 'extglob'
' RETURN


# this block build pkg - test
#trap '
#  printf \e[4m${BASH_SOURCE[0]##*-}\e[m...\e[31m error\e[m\n
#  if ((UID)); then
#    exit 1
#  else
#    exec bash --login
#  fi
#' ERR
