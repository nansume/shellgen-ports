#!/bin/sh
# +static +static-libs -doc -xstub +diet -musl +stest +strip +x32

BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local MAKEFLAGS=

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

make -j "$(nproc)" V='0' \
  CC="${CC}" \
  DESTDIR=${ED} \
  prefix="/" \
  libdir="/$(get_libdir)" \
  LIBCGETOPT="1" \
  WITHOUT_GETTEXT="1" \
  CFLAGS="${CFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  all install \
  || die "Failed make build"
