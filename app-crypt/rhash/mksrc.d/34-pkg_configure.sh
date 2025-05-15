#!/bin/sh
# -static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Console utility and library for computing and verifying file hash sums"
HOMEPAGE="https://rhash.sourceforge.net/"
LICENSE="0BSD"
IUSE="-debug -nls +ssl -static +static-libs +shared"
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

#append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

./configure \
  --cc="${CC}" \
  --prefix="/usr" \
  --exec-prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sysconfdir="${EPREFIX%/}/etc" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --mandir="${DPREFIX}/share/man" \
  --target="$(tc-chost)" \
  --disable-debug \
  --disable-openssl-runtime \
  $(use_enable 'ssl' openssl) \
  --enable-static \
  $(use_enable 'shared' lib-shared) \
  $(use_enable 'static-libs' lib-static) \
  $(use_enable 'nls' gettext) \
  --extra-cflags="${CFLAGS}" \
  --extra-ldflags="${LDFLAGS}" \
  || die "configure... error"

sed -i -e "s:\$(LIBDIR):${ED}\$(LIBDIR):" librhash/Makefile

#mkdir -pm 0755 "${ED}"/$(get_libdir)/
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so.1 &&
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so &&
#printf %s\\n "fix symlink: lib${PN}.so.1.4.4"

printf "Configure directory: ${PWD}/... ok\n"
