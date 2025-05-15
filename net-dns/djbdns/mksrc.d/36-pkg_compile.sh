#!/bin/sh
# +static -static-libs -shared -upx +patch -doc -xstub +diet -musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/net-dns/djbdns/djbdns-1.05-r40.ebuild

inherit toolchain-funcs install-functions

DESCRIPTION="Fast, reliable, simple package for creating and reading constant databases"
HOMEPAGE="http://cr.yp.to/cdb.html"
LICENSE="public-domain"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local EPREFIX=${EPREFIX%/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# Now move the man pages under ${S} so that user patches can be
# applied to them as well in src_prepare().
#mv "${PN}-man" "${P}/man" || die "failed to transplant man pages"

# Change `head -X` to the posix-compatible `head -nX` within the
# Makefile. We do this with sed instead of a patch because the ipv6
# patch uses some of the surrounding lines; we'd need two versions
# of the patch.
sed \
  -e 's/head[[:space:]]\{1,\}\-\([0-9]\{1,\}\)/head -n\1/g' \
  -i Makefile \
  || die 'failed to sed head in the Makefile'

# Bug 927539. This is beyond our ability to realistically fix due
# to patch conflicts.
#append-cflags $(test-flags-CC -Wno-error=incompatible-pointer-types)

printf '%s\n' "${CC} ${CFLAGS}" > conf-cc || die
printf '%s\n' "${CC} ${LDFLAGS}" > conf-ld || die
printf '%s\n' "${EPREFIX}/usr" > conf-home || die

emake AR="ar" RANLIB="ranlib"

insinto /etc
: doins dnsroots.global
mv -n ${BUILD_DIR}/dnsroots.global "${ED}"/etc/dnsroots.global.sample

into /usr
dobin *-conf dnscache tinydns walldns rbldns pickdns axfrdns \
  *-get *-data *-edit dnsip dnsipq dnsname dnstxt dnsmx \
  dnsfilter random-ip dnsqr dnsq dnstrace dnstracesort

if use 'ipv6'; then
  dobin dnsip6 dnsip6q
fi

dodoc CHANGES README

doman man/*.[158]

#readme.gentoo_create_doc

rm -- Makefile
