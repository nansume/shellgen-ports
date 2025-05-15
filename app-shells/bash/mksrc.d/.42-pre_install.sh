#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-06 20:00 UTC - fix: near to compat-posix, no-posix: local VAR

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
BUILD_SH='bash'  # gnu-ext, no-posix, compat-posix-support

export BUILD_DIR

local XLIB='libfakeroot.so'; local MAKEFLAGS=${MAKEFLAGS}; local MK

test -d "${BUILD_DIR}" || return 0
cd ${BUILD_DIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

MAKEFLAGS=$(printf %s " ${MAKEFLAGS} " | sed 's| --jobs=[0-9][0-9]\? | |;s|^ *||;s| *$||')

umask u=rwx,g=rx,o=rx
# mingetty fix: <sbin>
mkdir -pm 0755 "${INSTALL_DIR}/bin/" "${INSTALL_DIR}/sbin/" "${INSTALL_DIR}/man/"
mkdir -pm 0755 "${INSTALL_DIR}/usr/share/man/man1"  # fix: suckless mandir

ln -sf ../bin "${INSTALL_DIR}/usr/"
ln -sf ../lib "${INSTALL_DIR}/usr/"
ln -sf ../${LIB_DIR} "${INSTALL_DIR}/usr/"
#ln -sf ../lib32 ${INSTALL_DIR}/usr/lib
ln -sf ../sbin "${INSTALL_DIR}/usr/"

MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})  # IFS nl --> space, otherwise no work.

test -x "/opt/xbin/${BUILD_SH}" && ln -sf "${BUILD_SH}" /opt/xbin/sh &&
printf %s\\n "ln -sf ${BUILD_SH} -> /opt/xbin/sh"

local IFS="$(printf '\n\t') "

if test -r 'setup.py'; then  # python2 or python3
  true  # skip: Makefile call <pip install --ignore-installed .>
  MAKEFLAGS=
# no use - replace auto find makefile, see below <auto-find-makefile>
#elif [[ -f Makefile || -f GNUmakefile || -f makefile ]]; then
#  #MAKEFLAGS=${MAKEFLAGS/ PREFIX=\//&${INSTALL_DIR#/}}
#  #MAKEFLAGS=${MAKEFLAGS/ prefix=\//&${INSTALL_DIR#/}}
#  #MAKEFLAGS=${MAKEFLAGS/ USRDIR=\//&${INSTALL_DIR#/}}
#  . runverb \
#  make ${MAKEINSTALL[@]} install
elif test -x 'b2'; then  # cmake - bootstrap?
  # i2pd fix
  #MYCONF=(${MYCONF[@]/-prefix=*/-prefix=$INSTALL_DIR})
  MYCONF=$(mapsetre '--libdir=*' "--libdir=${INSTALL_DIR}/${LIB_DIR}" ${MYCONF})
  MYCONF=$(mapsetre '--includedir=*' "--includedir=${INSTALL_DIR}/${INCDIR}" ${MYCONF})
  # all
  . runverb \
  ./b2 ${MYCONF} install
  MAKEFLAGS=
fi


###############################################################################
####  auto-find-makefile  ####  fix add support: Makefile.no-imake  ###########
###############################################################################
test -n "${MAKEFILE}" && {
  MAKEFLAGS=$(printf %s " ${MAKEFLAGS} " | sed "s| -f [^ ]* | -f ${MAKEFILE} |;s|^ *||;s| *$||")
}
for MK in *; do
  test -n "${MAKE}" || break
  test -f "${MK}" || continue
  case ${MK} in [Mm]akefile.*|[Mm]akefile|GNUmakefile|${XMKFILE});; *) continue;; esac
  test -n "${MAKEFLAGS}" || break  # no required
  test -r 'setup.py' && break  # Makefile call <./setup.py build>
  # .am .in - skip, no-Unix drop: .win .msc .bcb
  case ${MK} in *'.am'|*'.in'|*'.win'*|*'.msc'*|*'.bcb'*) continue;; esac
  MK=${MK##*/}
  MAKEFILE=${MK}
  case ' '${MAKEFLAGS}' ' in *' -f '*);; *) MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }-f ${MK}";; esac
  # -f Makefile || -f GNUmakefile || -f makefile || -f ${XMKFILE} || Makefile.no-imake
  #XLIB=$(findlib ${XLIB}) || exit
  XLIB=${XLIB##*/}
  #. runverb LD_PRELOAD=${XLIB:?} make ${MAKEFLAGS[@]} install
  printf %s\\n "LD_PRELOAD=${XLIB:?} make ${MAKEFLAGS} install"
  #LD_PRELOAD=${XLIB} make ${MAKEFLAGS} install
  ${MAKE} ${MAKEFLAGS} ${INSTALL_OPTS} || pkg-install-bin-pn
  printf %s\\n "PWD='${PWD}'" "BUILD_DIR='${BUILD_DIR}'"
  break
done
if test -r '../meson.build' && test -x '/bin/python'; then
  printf %s\\n "PWD='${PWD}'" "BUILD_DIR='${BUILD_DIR}'"
  #set -- meson install --destdir "${INSTALL_DIR}" --no-rebuild
  #printf %s\\n "${*}" >&2
  #"$@"
  printf %s\\n "DESTDIR=${INSTALL_DIR} meson install --no-rebuild -C ${BUILD_DIR}" >&2
  DESTDIR="${INSTALL_DIR}" meson install --no-rebuild -C "${BUILD_DIR}"
elif test -r '../meson.build' && test -x '/bin/ninja' && test -x '/bin/python'; then
  DESTDIR="${INSTALL_DIR}" ninja -C "${BUILD_DIR}" install
fi
###############################################################################
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'

rm -- "${INSTALL_DIR}/usr/bin" "${INSTALL_DIR}/usr/lib"
rm -- "${INSTALL_DIR}/usr/${LIB_DIR}" "${INSTALL_DIR}/usr/sbin"
