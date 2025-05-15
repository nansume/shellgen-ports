# Copyright 1999-2024 Gentoo Authors
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# Distributed under the terms of the GNU General Public License v2
# -static -static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

: inherit autotools toolchain-funcs virtualx install-functions

DESCRIPTION="Lean FLTK based web browser"
HOMEPAGE="https://dillo-browser.github.io/"
LICENSE="GPL-3"
IUSE="-debug +doc +gif +jpeg +mbedtls +png +ssl -openssl +xembed +ipv6"
DOCS="AUTHORS ChangeLog README NEWS doc/*.txt doc/README"
S=${WORKDIR}

MYCONF="${MYCONF}
  --disable-threaded-dns
  $(use_enable 'debug' rtfl)
  $(use_enable 'gif')
  $(use_enable 'jpeg')
  $(use_enable 'mbedtls')
  $(use_enable 'openssl')
  $(use_enable 'png')
  $(use_enable 'ssl' tls)
  $(use_enable 'xembed')
  --enable-ipv6
  $(usex test --enable-html-tests=yes)
"

test "X${USER}" != 'Xroot' || return 0

if use 'test'; then
  # https://github.com/dillo-browser/dillo/pull/176
  # Upstream forgot to package tests for 3.1.0, I've done it
  # so we'll just move them into place for this release.
  rm -r -- "${S}"/test/html || die "Failed to remove broken test dir"
  mv -n "${WORKDIR}"/html -t "test/" || die "Failed to add good tests"
fi
