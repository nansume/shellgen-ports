#!/bin/sh
# -static +static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit toolchain-funcs

DESCRIPTION="tiny eventing, networking & crypto for async applications"
HOMEPAGE="https://github.com/uNetworking/uSockets"
LICENSE="Apache-2.0"
IUSE="-asio +libuv +ssl -test"

export PN PV EPREFIX ED

export AR="ar"
export VERSION="${PV%_*}"
export LIB="$(get_libdir)"
export WITH_OPENSSL="$(usex ssl 1 0)"
export WITH_LIBUV="$(usex libuv 1 0)"
export WITH_ASIO="$(usex asio 1 0)"
