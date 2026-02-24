#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Description: Async-capable DNS stub resolver library
# Homepage: https://www.corpit.ru/mjt/udns.html
# License: LGPL-2.1
# Depends: <deps>
# Date: 2026-02-09 22:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-libs/udns/udns-0.6.ebuild

PN="udns"
PV="0.6"
SRC_URI="https://deb.debian.org/debian/pool/main/u/udns/${PN}_${PV}.orig.tar.gz -> ${PN}-${PV}.tar.gz"
IUSE="+ipv6 +tools +static +static-libs +shared -doc (+musl) +stest +strip"
PROG="bin/dnsget"
STEST_OPT="-h"

pkgins(){ pkginst \
  "sys-devel/binutils6" \
  "sys-devel/gcc6" \
  "sys-devel/make" \
  "sys-libs/musl" \
  || die "Failed install build pkg depend... error"
}

prepare(){
  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  if use 'static-libs' || use 'static'; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-ldflags "-s -static --static"
    append-cflags -ffunction-sections -fdata-sections
  else
    append-flags -O2
  fi
  append-flags -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
}

build(){
  ./configure $(use_enable 'ipv6') || die "configure... error"

  make -j "$(nproc)" $(usex 'tools' static staticlib) sharedlib || die "Failed make build"

  dolib.so libudns.so.0 || die "make install... error"
  dosym libudns.so.0 /$(get_libdir)/libudns.so
  mv -v -n libudns.a -t "${ED}"/$(get_libdir)/

  if use 'tools'; then
    newbin dnsget dnsget
    newbin ex-rdns ex-rdns
    newbin rblcheck rblcheck
  fi

  doheader udns.h

  doman udns.3
  use 'tools' && doman dnsget.1 rblcheck.1

  use 'doc' && dodoc NEWS NOTES TODO
}
