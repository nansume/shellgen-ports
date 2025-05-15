#!/bin/sh
# -static +static-libs +shared -patch -doc -xstub -diet +musl +stest +strip +x32
# same to support: +static +static-libs +shared

DESCRIPTION="RTMP client, librtmp library intended to stream audio or video flash content"
HOMEPAGE="https://rtmpdump.mplayerhq.hu/"
LICENSE="LGPL-2.1 tools? ( GPL-2 )"
IUSE="-gnutls +ssl +static-libs +tools"
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="$(printf '\n\t') "
unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

# fix #571106 by restoring pre-GCC5 inline semantics
append-cflags -std=gnu89

# fix Makefile ( bug #298535 , bug #318353 and bug #324513 )
sed -i 's/\$(MAKEFLAGS)//g' Makefile \
 || die "failed to fix Makefile"
sed -i -e 's:OPT=:&-fPIC :' \
 -e 's:OPT:OPTS:' \
 -e 's:CFLAGS=.*:& $(OPT):' librtmp/Makefile \
 || die "failed to fix Makefile"

mkdir -pm 0755 "${ED}"/$(get_libdir)/pkgconfig/

make -j"$(nproc)" V='0' \
  CC="${CC}" \
  DESTDIR=${ED} \
  prefix="${EPREFIX%/}/usr" \
  bindir="/bin" \
  sbindir="/sbin" \
  libdir="/$(get_libdir)" \
  incdir='$(prefix)/include/librtmp' \
  mandir='$(prefix)/share/man' \
  OPT="${CFLAGS}" \
  XLDFLAGS="${LDFLAGS}" \
  CRYPTO=$(usex 'gnutls' GNUTLS OPENSSL) \
  SYS="posix" \
  all install \
  || die "Failed make build"

rm -- Makefile

printf %s\\n "Install: ${PN}"
