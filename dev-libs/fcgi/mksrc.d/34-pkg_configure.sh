#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# https://iso.netbsd.org/pub/NetBSD/NetBSD-current/pkgsrc/www/fcgi/index.html

inherit autotools install-functions

DESCRIPTION="FAST CGI(fcgi) is a language independent, high performant extension to CGI"
HOMEPAGE="http://www.fastcgi.com/"
HOMEPAGE="https://github.com/FastCGI-Archives/fcgi2"
LICENSE="FastCGI"
LICENSE="OML"
IUSE="-html"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

export LIBS="-lm"

#autoreconf --install
#./autogen.sh

#--host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make V='0' -j"$(nproc)" || die "Failed make build"

make DESTDIR="${ED}" LIBRARY_PATH="${ED}"/$(get_libdir) install

rm -- Makefile Makefile.*

einstalldocs

# install the manpages into the right place
doman doc/*.1 doc/*.3

# Only install the html documentation if USE=html
if use 'html'; then
  docinto html
  dodoc -r doc/*/* images
else
  rmdir "${ED}"/usr/share/doc/${PN}-${PV}/html/
fi

# install examples in the right place
docinto examples
dodoc examples/*.c

# no static archives
find "${ED}" -name '*.la' -delete || die

printf %s\\n "Install: ${PN}"
