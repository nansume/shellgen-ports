#!/bin/sh
# +static -static-libs -shared -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="Converter for Microsoft Word, Excel, PowerPoint and RTF files to text"
HOMEPAGE="http://www.wagner.pp.ru/~vitus/software/catdoc/"
LICENSE="GPL-2"
IUSE="-tk"
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

unset MAKEFLAGS

test "X${USER:?}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 "${ED}"/usr/share/man/man1/

make installroot=${ED} install || die "make install... error"
