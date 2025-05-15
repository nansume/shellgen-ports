#!/bin/sh
# +static -static-libs -doc -xstub -diet +musl +stest +strip +x32

NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS=${NL}
local MAKEFLAGS=

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"


sed -i \
  -e "/^CFLAGS = /s/ -O2 / ${CFLAGS} /" \
  -e "/^LDFLAGS = /s/ -O2 / ${LDFLAGS} /" \
  -e "s/^PLUGINS = .*/PLUGINS = /" \
  Makefile.Linux

make -j "$(nproc --ignore=1)" V='0' \
  CC="${CC}" \
  DESTDIR=${ED} \
  prefix='' \
  -f "Makefile.Linux" \
  all \
  || die "Failed make build"

mkdir -pm 0755 "${ED}"/bin/

mv -n bin/${PN} bin/ftppr bin/mycrypt bin/pop3p bin/proxy bin/socks bin/tcppm bin/udppm "${ED}"/bin/ &&
printf %s\\n "Install: ${PN} ftppr mycrypt pop3p proxy socks tcppm udppm bin/"
