#!/bin/sh
# +static +static-libs +shared -patch -doc -xstub +diet -musl +stest +strip +x32

# http://gpo.zugaina.org/net-ftp/frox

# Transparent ftp-proxy via HTTP

NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}

local IFS=${NL}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${BUILD_DIR}" || return 0
cd ${BUILD_DIR}/

test -x './configure' || return

./configure \
  CC="${CC}" \
  --prefix="${EPREFIX}" \
  --sbindir="${EPREFIX%/}/sbin" \
  --datadir="${DPREFIX}/share" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"
