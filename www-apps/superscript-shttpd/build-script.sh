#!/bin/sh /usr/ports/profiles/libexec.d/ebuild-compat.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-28 13:00 UTC - last change
# Build with useflag: +static -static-libs -shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# https://iso.netbsd.org/pub/NetBSD/NetBSD-current/pkgsrc/www/superscript-shttpd/index.html

# TODO: build against dietlibc

#inherit _install-functions static

DESCRIPTION="HTTP daemons designed to complement publicfile"
HOMEPAGE="<url>"
LICENSE="<license>"
PN="shttpd"
XPN="superscript-shttpd"
PV="0.53"
PATCH_URI="http://cvsweb.netbsd.org/bsdweb.cgi/~checkout~/pkgsrc/www/superscript-shttpd/patches"
HASH="179e52631ce26d2e3b6137596466b1764ba276ea"  # v0.53
SRC_URI="
  http://localhost/pub/distfiles/${PN}-${PV}.tar.gz
  #https://github.com/SuperScript/shttpd/archive/${HASH}.tar.gz -> ${PN}-${PV}.tar.gz
  ${PATCH_URI}/patch-Makefile -> shttpd-0.53-Makefile.patch
  ${PATCH_URI}/patch-leapsecs__read.c -> shttpd-0.53-leapsecs_read_c.patch
"
IUSE="+static -static-libs -shared (-bundled) -doc (-diet) (+musl) +stest +strip"
TARGET_INST=

pkgins() { pkginst \
  "#dev-libs/dietlibc  #dietlibc1 # 0.34-x32 or 0.35-x86" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

src_prepare() {
  patch -p0 -E < "${FILESDIR}"/shttpd-0.53-Makefile.patch
  patch -p0 -E < "${FILESDIR}"/shttpd-0.53-leapsecs_read_c.patch

  echo "/usr/libexec/${PN}" > conf-home
  echo "${ED}" > conf-destdir

  #append-cflags -I/usr/include/bsd
  append-cflags -std=c89

  sed -e '/^#include "leapsecs.h"$/a #include <stdlib.h>' -i leapsecs_read.c
  sed -e '/^#include "error.h"$/a #include <errno.h>' -i *.c
  #sed -e '/^#include "exit.h"$/a #include <stdio.h>' -i auto-str.c
  #sed -e '/^#include "env.h"$/a #include <math.h>' -i redir-httpd.c
}

src_configure() { :;}

src_compile() {
  make || die "Failed make build"
}

src_install() {
  mkdir -m 0755 "${ED}"/usr/ "${ED}"/usr/libexec/ "${ED}"/usr/libexec/${PN}/
  mv -v \
    cgi-config cgi-env cgi-example cgi-httpd cgi-success cgiuser-httpd \
    cgiuser-config cgi-dispatch echo-config echo-httpd redir-config \
    redir-httpd redir-data constant-config constant-httpd utime \
    -t "${ED}"/usr/libexec/${PN}/

  echo "Install: ${PN}... ok"
}
