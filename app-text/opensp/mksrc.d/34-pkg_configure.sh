#!/bin/sh
# +static +static-libs +shared -upx -patch -doc -xstub -diet +musl -stest +strip +x32

DESCRIPTION="A free, object-oriented toolkit for SGML parsing and entity management"
HOMEPAGE="https://openjade.sourceforge.net/"
LICENSE="MIT"
IUSE="-doc -nls +static-libs -test"
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX%/}
BUILD_DIR=${WORKDIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

append-cxxflags -std=gnu++11

./configure \
  CC="${CC}" \
  CXX="${CXX}" \
  CPP="${CPP}" \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datadir="${DPREFIX}/share/sgml/${PN}-${PV}" \
  --host=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --build=$(tc-chost | sed '/-musl/ s/-/-pc-/;s/musl/gnu/') \
  --enable-http \
  --enable-default-catalog="${EPREFIX}"/etc/sgml/catalog \
  --enable-default-search-path="${EPREFIX}"/usr/share/sgml \
  $(use_enable 'doc' doc-build) \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}" \
  || die "configure... error"

: sed -i -e "s:\$(PREFIX):${ED}:" Makefile
: sed -i -e "s:\$(LIBDIR):${ED}\$(LIBDIR):" librhash/Makefile

#mkdir -pm 0755 "${ED}"/$(get_libdir)/
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so.1 &&
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so &&
#printf %s\\n "fix symlink: lib${PN}.so.1.4.4"

: printf '%s\n' HAVE_FLTK=$(usex 'fltk' yes no) >> config.mak

printf "Configure directory: ${PWD}/... ok\n"
