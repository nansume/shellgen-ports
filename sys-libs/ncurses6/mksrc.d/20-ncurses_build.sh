#!/bin/sh

local WORKDIR=${WORKDIR}; local PKGNAME=${PKGNAME}; local MYCONF; local RMLIST

test "X${USER}" != 'Xroot' || return 0

export WORKDIR PKGNAME

cd "${DISTSOURCE}/" || exit

pkg-unpack PKGNAME=${PKGNAME} && USE_BUILD_ROOT='0'

cd "${WORKDIR}/" || exit

case ${XPN} in
  ncurses*w)
    MYCONF="${MYCONF:+${MYCONF} }--enable-widec"
  ;;
  *)
    MYCONF="${MYCONF:+${MYCONF} }--disable-widec"
  ;;
esac
case ${XPN} in
  ncursest*)
    MYCONF="${MYCONF:+${MYCONF} }--with-pthread"
    MYCONF="${MYCONF:+${MYCONF} }--enable-reentrant"
  ;;
  *)
    MYCONF="${MYCONF:+${MYCONF} }--without-pthread"
    MYCONF="${MYCONF:+${MYCONF} }--disable-reentrant"
  ;;
esac
if test "X${XPN}" = 'Xncurses'; then
  MYCONF="${MYCONF:+${MYCONF} }--includedir=${INCDIR}"
else
  MYCONF="${MYCONF:+${MYCONF} }--includedir=${INCDIR}/${XPN}"
fi

printf %s\\n "Configure directory: PWD='${PWD}'... ok"

./configure \
  --prefix=${SPREFIX} \
  --bindir=${SPREFIX%/}/bin \
  --sbindir=${SPREFIX%/}/sbin \
  --libdir=${SPREFIX%/}/${LIB_DIR} \
  --libexecdir=${DPREFIX}/libexec \
  --datarootdir=${DPREFIX}/share \
  --host=${CHOST} \
  --build=${CHOST} \
  $(use_enable 'rpath') \
  $(use_with 'shared') \
  $(use 'cxx' && use_with 'shared' cxx-shared) \
  --without-debug \
  $(use_with 'gpm') \
  $(use_with 'gpm' dlsym) \
  --without-libtool \
  --without-manpages \
  $(use 'static-libs' && use 'shared' || use_with 'shared') \
  $(use_with 'static-libs' normal) \
  $(use_with 'progs') \
  --enable-pc-files \
  --with-termlib \
  $(use_with 'ada') \
  $(use_with 'cxx') \
  $(use_with 'cxx' cxx-binding) \
  ${MYCONF} || exit

make || exit
make DESTDIR='/install' install || exit

cd "${INSTALL_DIR}/" || exit

post-inst-perm

RMLIST="$(pkg-rmlist)" pkg-rm

post-rm
pkg-rm-empty
use 'strip' && pkg-strip
pre-perm
