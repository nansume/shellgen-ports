#!/bin/sh
# +static +static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools flag-o-matic toolchain-funcs install-functions

DESCRIPTION="Full-text search engine with support for MySQL and PostgreSQL"
HOMEPAGE="https://sphinxsearch.com/"
LICENSE="GPL-2"
IUSE="-debug +id64 -mariadb -mysql -odbc -postgres -stemmer +syslog +xml -glibc"
IUSE="${IUSE} +static +static-libs +shared -doc +iconv (+musl) +stest +strip"
PV=${PV%-*}
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}; local D=${ED}

unset MAKEFLAGS

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# drop nasty hardcoded search path breaking Prefix
# We patch configure directly since otherwise we need to run
# eautoreconf twice and that causes problems, bug 425380
sed -e 's/\/usr\/local\//\/someplace\/nonexisting\//g' -i configure || die

if use 'mariadb'; then
  sed -e 's/mysql_config/mariadb_config/g' -i configure || die
fi

# Fix QA compilation warnings.
sed -e '19i#include <string.h>' -i api/libsphinxclient/test.c || die

#pushd api/libsphinxclient || die
#autoreconf --install  #-fi
#popd || die

# Drop bundled code to ensure building against system versions. We
# cannot remove libstemmer_c since configure updates its Makefile.
#rm -rf libexpat || die

# bug #854738
append-flags "-fno-strict-aliasing"
#filter-lto
# This code is no longer maintained and not compatible with modern C/C++ standards, bug #880923
append-cflags "-std=gnu89"
append-cxxflags "-std=c++11"

# fix libiconv detection - it with musl no work!
#use !glibc && export ac_cv_search_iconv=-liconv

./configure \
  ${MYCONF} \
  --sysconfdir="${EPREFIX}/etc/${PN}" \
  $(use_enable 'id64') \
  $(use_with 'debug') \
  $(use_with 'mariadb' mysql) \
  $(use_with 'odbc' unixodbc) \
  $(use_with 'postgres' pgsql) \
  $(use_with 'stemmer' libstemmer) \
  $(use_with 'syslog' syslog) \
  $(use_with 'xml' libexpat ) \
  $(usex !iconv --without-iconv) \
  --without-re2 \
  || die "configure... error"

cd api/libsphinxclient/ || die
./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share" \
  STRIP=: \
  || die "configure... error"

cd ${BUILD_DIR}/ || return
printf "Configure directory: ${PWD}/... ok\n"

make AR="ar" || die "Failed make build"

make -j1 -C api/libsphinxclient || die "Failed make build"

make DESTDIR="${ED}" install || die "make install... error"
make DESTDIR="${ED}" -C api/libsphinxclient install || die "make install... error"

rm -- Makefile

# Remove unneeded empty directories.
rmdir "${ED}"/var/lib/data/ "${ED}"/var/lib/log/

dodoc doc/*

#keepdir /var/lib/sphinx
#keepdir /var/log/sphinx

#newinitd "${FILESDIR}"/searchd.rc searchd

# Install - PHP api for sphinx search engine
mkdir -pm 0755 -- "${ED}"/usr/share/php/${PN}/api/
mv -n api/*.php -t "${ED}"/usr/share/php/${PN}/api/