# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
#  fix: 2021-2023 Artjom Slepnjov, Shellgen

local DEFAULT_CFLAGS LDFLAGS='-mx32'

# add: support x32
test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "X${ABI}" != 'Xx32' && return

# Clean out hardcoded flags that openssl uses
DEFAULT_CFLAGS=$(grep ^CFLAG= Makefile | LC_ALL=C sed \
  -e 's:^CFLAG=::' \
  -e 's:\(^\| \)-fomit-frame-pointer::g' \
  -e 's:\(^\| \)-O[^ ]*::g' \
  -e 's:\(^\| \)-march=[^ ]*::g' \
  -e 's:\(^\| \)-mcpu=[^ ]*::g' \
  -e 's:\(^\| \)-m[^ ]*::g' \
  -e 's:^ *::' \
  -e 's: *$::' \
  -e 's: \+: :g' \
  -e 's:\\:\\\\:g'
)

# Now insert clean default flags with user flags
sed -i \
  -e "/^CFLAG/s|=.*|=${DEFAULT_CFLAGS} ${CFLAGS-}|" \
  -e "/^LDFLAGS=/s|=[[:space:]]*$|=${LDFLAGS-}|" \
  -e "/^SHARED_LDFLAGS=/s|=-.*$|=${LDFLAGS-}|" \
  Makefile
