#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs install-functions

DESCRIPTION="Hardware detection tool used in SuSE Linux"
HOMEPAGE="https://github.com/openSUSE/hwinfo/"
LICENSE="GPL-2"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd "${BUILD_DIR}/" || return

CFLAGS=${CFLAGS/-no-pie }

# Respect AR variable.
sed \
 -e 's:ar r:$(AR) r:' \
 -i src/Makefile src/isdn/Makefile src/ids/Makefile src/smp/Makefile src/hd/Makefile || die

# Respect LDFLAGS.
sed -i -e 's:$(CC) $(CFLAGS):$(CC) $(LDFLAGS) $(CFLAGS):' src/ids/Makefile || die

# Respect MAKE variable. Skip forced -pipe and -g.
sed \
 -e 's:make:$(MAKE):' \
 -e 's:-pipe -g::' \
 -i Makefile Makefile.common || die
rm -f git2log || die

make -j1 AR="ar" CC="${CC}" HWINFO_VERSION="${PV}" \
  RPM_OPT_FLAGS="${CFLAGS}" LIBDIR="${EPREFIX}/$(get_libdir)" \
  || die "Failed make build"

make DESTDIR=${ED} LIBDIR="/$(get_libdir)" install || die "make install... error"
keepdir /var/lib/hardware/udi

dodoc README*
docinto examples
dodoc doc/example*.c
doman doc/*.1 doc/*.8

rm -- Makefile

printf %s\\n "Install: ${PN}"
