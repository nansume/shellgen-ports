#!/bin/sh

local IFS="$(printf '\n\t')"; IFS=" ${IFS%?}"

test "X${USER}" != 'Xroot' || return 0

cd "${WORKDIR}/" || exit

if use 'static'; then
  export CC="gcc -static --static"
  export LDFLAGS='-s -static --static'

  MAKEFLAGS=$(mapsetre 'CC=*' '' ${MAKEFLAGS})
fi

MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --sbindir=${SPREFIX%/}/sbin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --libexecdir=${DPREFIX}/libexec
 --datarootdir=${DPREFIX}/share
 --host=${CHOST}
 --build=${CHOST}
 --disable-static
 --disable-shared
"

MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})
MYCONF=$(mapsetnorm ${MYCONF})

. runverb ./configure ${MYCONF} || exit

. runverb ${IONICE_COMM} make ${MAKEFLAGS} || exit

make DESTDIR='/install' ${MAKEFLAGS} install || exit

cd ${INSTALL_DIR}/ || exit

ln -sf 'pkgconf' bin/'pkg-config' && printf %s\\n "ln -sf pkgconf bin/pkg-config"
