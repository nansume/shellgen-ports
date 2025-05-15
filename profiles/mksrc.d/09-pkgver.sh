#!/bin/sh
# Copyright (C) 2021-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-07 16:00 UTC - fix: near to compat-posix, no-posix: local VAR
# Date: 2024-10-07 18:00 UTC - last change

local IFS="$(printf '\n\t')"; IFS=${IFS%?}
local OLDPN=${PN}
local PN=${PN#*-}
local XPATH="/etools.d"  # pre add tools path

export CATEGORY OLDPN

test -f "gitcommit" && read -r GITHASH < 'gitcommit'
test -f "version"   && read -r PV < 'version'

test -n "${GITHASH}" &&
sed \
  -e "s/\${GITCOMMIT}/${GITHASH}/g" \
  -e "s/\${GITHASH}/${GITHASH}/g" \
  -e "s/\${COMMIT}/${GITHASH}/g" \
  -e "s/\${HASH}/${GITHASH}/g" \
  -i 'src_uri.lst'

test -n "${PV}" && sed -e "s/\${PV}/${PV}/g" -i 'src_uri.lst'

read -r PF < 'src_uri.lst'

test -d "${XPATH}" || XPATH="/usr/ports/profiles/etools.d"
test "x${SN}" != "x${SN%%_*}" && SN="${SN%%_*}-${SN#*_}"

CATEGORY=${PDIR%/?*}
CATEGORY=${CATEGORY##*/}

PF=${PF%%#*}
PF="${PF%${PF##*[![:blank:]]}}"
PF=${PF##*[/ ]}

PF=$("${XPATH}/"vsrcname ${PF}) || exit

# bug: PN=ar PV=busybox-1.34.1.tar.bz2 PV=.bz2 PV=2
#PV=${PF##*$PN[-_]}
#PV=${PV##*[!.]$PN}

PV=$(lower ${PF})
PV=${PV#$OLDPN[2-9][-_]}
PV=${PV#$OLDPN[-_]}
PV=${PV#$OLDPN}
PV=${PV#$PN[2-9][-_]}
PV=${PV#$PN[-_]}
PV=${PV#$PN}
PV="${PV#${PN//-/_}}"  # testing 2024.10.07

#while case ${PV} in [!0-9]*);; *)! true;; esac; do PV=${PV#?}; done
PV="${PV#${PV%%[0-9]*}}"

printf %s\\n "PN='${PN}'" "PF='${PF}'" "PV='${PV}'"

PV=${PV#[A-z][A-z]*[-]}
PV=${PV#[A-z]*[a-z][a-z][-_]}
PV=${PV%.*}
PV=${PV%.tar}

test -n "${PV-}" || PV="$(date '+%Y.%m.%d')"

PKGNAME=${PF%[-_]$PV*}
PKGNAME=${PKGNAME%$PV*}
PKGNAME=${PKGNAME%.tar.*}  # if <PV empty> then...
PKGNAME=${PKGNAME%-src}    # test - remove duplicat: -src-src|-src

PV=$(printf %s "${PV}" | sed 's/+git/-/')
PV=$(printf %s "${PV}" | sed 's/-upstream//')
PV=$(printf %s "${PV}" | sed 's/-stable//')
PV=${PV%[.-]source}  # `2.33.1.source` --> `2.33.1`
PV=${PV%-autotools}
PV=$(printf %s "${PV}" | sed 's/-src//')
PV=$(printf %s "${PV}" | sed 's/dev//')
PV=$(printf %s "${PV}" | sed 's/_/./g')

PV=${PV#v}

printf %s\\n "CATEGORY='${CATEGORY}'"

: ${PKGNAME:=$OLDPN}

test "X${USER}" != 'Xroot' || printf %s\\n "PKGNAME='${PKGNAME}'" "PV='${PV}'"
