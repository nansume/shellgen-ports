#!/bin/sh
# musl: -static +static-libs +shared -upx +patch -doc -xstub -diet +musl +stest +strip +x32
# diet: +static +static-libs -shared -upx +patch -doc -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs

export ED BUILD_DIR

DESCRIPTION="Bruce Guenter's Libraries Collection"
HOMEPAGE="http://untroubled.org/bglibs/"
LICENSE="LGPL-2.1+"
IUSE="-doc"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# disable tests as we want them manually
sed -i '/^all:/s|selftests||' Makefile || die
sed -i '/selftests/d' TARGETS || die

printf '%s\n' "${ED}/bin" > conf-bin || die
printf '%s\n' "${ED}/$(get_libdir)/bglibs" > conf-lib || die
printf '%s\n' "${ED}/usr/include" > conf-include || die
printf '%s\n' "${ED}/usr/share/man" > conf-man || die
printf '%s\n' "${CC} ${CFLAGS}" > conf-cc || die
printf '%s\n' "${CC} ${LDFLAGS} -g0" > conf-ld || die
