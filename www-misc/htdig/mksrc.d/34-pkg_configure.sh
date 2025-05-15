#!/bin/sh
# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit autotools flag-o-matic install-functions

DESCRIPTION="HTTP/HTML indexing and searching system"
HOMEPAGE="https://htdig.sourceforge.net/"
LICENSE="GPL-2"
IUSE="+ssl"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.in db/configure.in || die

# bug #787716
append-cxxflags -std=c++14

printf "${PV%${PV##*.[0-9]}}" > .version

autoreconf --install

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share" \
  --mandir="${DPREFIX}/share/man" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --with-config-dir="${EPREFIX}"/etc/${PN} \
  --with-default-config-file="${EPREFIX}"/etc/${PN}/${PN}.conf \
  --with-database-dir="${EPREFIX}"/var/lib/${PN}/db \
  --with-cgi-bin-dir="${EPREFIX}"/var/www/localhost/cgi-bin \
  --with-search-dir="${EPREFIX}"/var/www/localhost/htdocs/${PN} \
  --with-image-dir="${EPREFIX}"/var/www/localhost/htdocs/${PN} \
  $(use_with 'ssl') \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make V='0' -j"$(nproc)" || die "Failed make build"

make DESTDIR=${ED} install || die "make install... error"

rm -- Makefile*

sed -i "s:${ED}::g" \
  "${ED}"/etc/${PN}/${PN}.conf \
  "${ED}"/bin/rundig \
  || die "sed failed (removing \${ED} from installed files)"

# symlink htsearch so it can be easily found. see bug #62087
dosym ../../var/www/localhost/cgi-bin/htsearch /usr/bin/htsearch

# no static archives
find "${ED}" -name '*.la' -delete || die
