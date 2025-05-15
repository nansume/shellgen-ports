#!/bin/sh

export WORKDIR

FILESDIR=${DISTSOURCE}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

{ use !diet && use 'shared' && use 'static';} || return 0

cd ${BUILD_DIR}/ || return

test -n "${CC}"       && local CC="gcc"
test -n "${CXX}"      && local CXX="g++"
test -n "${CPP}"      && local CPP="gcc -E"
test -n "${CFLAGS}"   && local CFLAGS=
test -n "${CXXFLAGS}" && local CXXFLAGS=
test -n "${CPPFLAGS}" && local CPPFLAGS=
test -n "${FFLAGS}"   && local FFLAGS=
test -n "${FCFLAGS}"  && local FCFLAGS=
test -n "${LDFLAGS}"  && local LDFLAGS=

case $(tc-abi-build) in
  'x32')   append-flags -mx32 -msse2 ;;
  'x86')   append-flags -m32         ;;
  'amd64') append-flags -m64 -msse2  ;;
esac
append-flags -O2 -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')

./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --enable-shared \
  --disable-static \
  $(use_enable 'nls') \
  $(use_enable 'rpath') \
  || die "configure... error"

make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  prefix='' \
  libdir="/$(get_libdir)" \
  includedir="/usr/include" \
  all \
  || die "Failed make build"

make DESTDIR=${ED} install || die "make install... error"

MYCONF=${MYCONF/--enable-shared/--disable-shared}

rm -r -- "Makefile" "${BUILD_DIR}/" "${ED}/bin/"* "${ED}/$(get_libdir)/"*.la

cd "${FILESDIR}/" || die "distsource dir: not found... error"

gunzip -dc "${PF}" | tar -C "${PDIR%/}/${SRC_DIR}/" -xkf - || die
mv -n ${PDIR%/}/${SRC_DIR}/${PN}-${PV} ${BUILD_DIR} || die

cd ${BUILD_DIR}/ || die

src-patch "${FILESDIR}/"*.patch || : die

autoreconf --install