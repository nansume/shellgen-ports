#!/bin/sh
# +static -static-libs -shared -patch -doc -xstub +diet -musl +stest +strip +x32

DESCRIPTION="A Markdown-to HTML translator written in C"
HOMEPAGE="http://www.pell.portland.or.us/~orc/Code/discount/"
LICENSE="BSD"
IUSE="+static -static-libs -shared -doc -minimal +diet (-musl) -xstub +stest -test +strip"
NL="$(printf '\n\t')"; NL=${NL%?}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

local IFS="${NL} "

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

export FLAGS=${CFLAGS}

sed -i \
  -e 's/\(LDCONFIG=\).*/\1:/' \
  -e 's/\(.\)\$FLAGS/& \1$LDFLAGS/' \
  configure.inc || die "sed configure.inc failed"

CC="${CC}" \
./configure.sh \
  --prefix="${EPREFIX}" \
  --execdir="${EPREFIX%/}/bin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --mandir="${EPREFIX}/usr/share/man" \
  $(usex 'shared' --shared) \
  $(usex 'shared' --pkg-config) \
  $(usex minimal '' --enable-all-features) \
  --debian-glitch \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make V='0' \
  DESTDIR=${ED} \
  INCDIR="/usr/include" \
  MANDIR="/usr/share/man" \
  $(usex 'minimal' install install.everything) \
  SAMPLE_PFX="${PN}-" \
  || die "make install... error"

rm -- Makefile

mv -n mktags "${ED}"/bin/
