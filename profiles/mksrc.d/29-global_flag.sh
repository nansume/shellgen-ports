#!/bin/sh
# Copyright (C) 2020-2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-06 13:00 UTC - fix: near to compat-posix
# no-posix: local X=${X//a/b} X=${X/a/b} X=${X/a}
# Date: 2024-07-18 15:00 UTC - last change

local IFS="$(printf '\n\t')"; IFS=" ${IFS%?}"; local LIST; local S; local X

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

: ${PDIR:?} ${CATEGORY:?} ${PN:?}
# .global-flag.d
for S in "${PDIR%/}/global.d/"*".lst"; do
  test -f "${S}" &&
  while IFS= read -r S; do
    S=${S%%#*}
    S="${S%${S##*[![:space:]]}}"
    X=${S%%: *}
    test -n "${S}" &&
    case ":${CATEGORY}/${PN}:" in
      :${S%%: *}: | :${S%/\*: *}/*: | ${S%\*/\*: *}:*/*: | :*/${X#\*/}: )
        S="${S#${S%%: *}:}"
        LIST="${LIST:+${LIST} }${S#${S%%[![:space:]]*}}"
      ;;
    esac
  done < ${S}
done

for X in ${LIST}; do
  printf %s\\n "STRING='${X}'"
  case ${X} in
    '-std=gnu89'|'-std=c89'|'-std=gnu99'|'-std=c99'|'-std=gnu11'|'-std=c11'|'-std=gnu17'|'-std=c17')
      #CFLAGS+=" -O0 -std=gnu89 -Wdeprecated-declarations
      CFLAGS="${CFLAGS:+${CFLAGS} }${X}"
    ;;
    '-ffast-math')
      CFLAGS="${CFLAGS:+${CFLAGS} }${X}"
      CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }${X}"
      printf " \e[1;32m+\e[m global_flag... append flags\n"
    ;;
    '-std=gnu++98'|'-std=c++98'|'-std=gnu++11'|'-std=c++11'|'-std=gnu++14'|'-std=c++14'|'-fpermissive')
      CXXFLAGS="${CXXFLAGS:+${CXXFLAGS} }${X}"
      printf " \e[1;32m+\e[m global_flag... cxxflags custom\n"
    ;;
    'maxgcc'|'-O3')
      CFLAGS=$(mapsetre '-O?' '-O3' ${CFLAGS})
      CXXFLAGS=$(mapsetre '-O?' '-O3' ${CXXFLAGS})
      printf " \e[1;32m+\e[m global_flag: /-O?/-O3/... replace\n"
    ;;
    'no-fpmath'|'+mfpmath'|'+mfpmath='*)
      # i686
      CFLAGS=$(mapsetre '-mfpmath=sse,387' '' ${CFLAGS})
      CXXFLAGS=$(mapsetre '-mfpmath=sse,387' '' ${CXXFLAGS})
      printf " \e[1;32m+\e[m global_flag: cflags... \e[0;33mremove\e[m\n"
    ;;
    'change-time')
      #change-time ${INSTALL_DIR}/
    ;;
    'gnu-chost'|'chost-musl-gnu')  # testing
      MYCONF=$(printf '%s' "${MYCONF}" | sed '/-linux-musl/ s/-linux-musl/-pc-linux-gnu/')
    ;;
    'chost-diet-musl')  # testing
      MYCONF=$(printf '%s' "${MYCONF}" | sed 's/-pc-linux-dietlibc/-linux-musl/')
    ;;
    'chost-diet-gnu')  # testing
      MYCONF=$(printf '%s' "${MYCONF}" | sed 's/-pc-linux-dietlibc/-pc-linux-gnu/')
    ;;
    're-conf-datadir'|'-datadir'|'-datadir='*)
      MYCONF=$(printf '%s' "${MYCONF}" | sed 's|-datarootdir=|-datadir=|')
    ;;
    'rm-conf-build'|'++build'|'++build='*)
      MYCONF=$(mapsetre '--build=*' '' ${MYCONF})
    ;;
    'rm-conf-host'|'++host'|'++host='*)
      MYCONF=$(mapsetre '--host=*' '' ${MYCONF})
    ;;
    'rm-conf-include'|'++includedir'|'++includedir='*)
      MYCONF=$(mapsetre '--includedir=*' '' ${MYCONF})
    ;;
    'rm-conf-libexecdir'|'++libexecdir'|'++libexecdir='*)
      MYCONF=$(mapsetre '--libexecdir=*' '' ${MYCONF})
    ;;
    'makeflag-jobs1')
      MAKEFLAGS=$(mapsetre '--jobs=?*' '--jobs=1' ${MAKEFLAGS})
    ;;
    # fix: -static && +static-libs (no-disable static libs)
    [+-]'static'|[+-]'static-libs')  # testing
      export IUSE="${X}"
      X=${X#[+-]}
      if { use !static-libs && use !static ;}; then
        MYCONF="${MYCONF:+${MYCONF} }$(use_enable static)"
      elif use ${X}; then
        MYCONF="${MYCONF:+${MYCONF} }$(use_enable ${X} static)"
      fi
    ;;
    # bug: -static +static-libs == --disable-static (disable static libs)
    [+-]'rpath'|[+-]'nls'|[+-]'static'|[+-]'static-libs'|[+-]'shared')
      export IUSE="${X}"
      X=${X#[+-]}
      MYCONF="${MYCONF:+${MYCONF} }$(use_enable ${X%-libs})"
    ;;
    '++disable+rpath'|'++without+rpath'|'++disable+nls'|'++disable+static'|'++enable+shared')
      X=$(printf %s "${X}" | sed 's/+/-/g')
      MYCONF=$(mapsetre "${X}" '' ${MYCONF})
    ;;
    '--disable-rpath'|'--without-rpath'|'--disable-nls'|'--disable-static'|'--enable-shared')
      MYCONF="${MYCONF:+${MYCONF} }${X}"
    ;;
    '--disable-asm'|'no-asm')
      # support x32
      test "X${ABI}" != 'Xx32' && continue
      MYCONF="${MYCONF:+${MYCONF} }${X}"
    ;;
  esac
done
# -march=athlon64-sse3

CFLAGS=$(mapsetnorm ${CFLAGS})
CXXFLAGS=$(mapsetnorm ${CXXFLAGS})

if ! use 'nopie'; then
  CFLAGS=${CFLAGS/-no-pie }
  CXXFLAGS=${CXXFLAGS/-no-pie }
  printf %s\\n "CFLAGS, CXXFLAGS - remove: -no-pie"
fi