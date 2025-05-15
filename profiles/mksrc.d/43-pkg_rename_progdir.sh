#!/bin/sh
# Copyright (C) 2024-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-07-30 12:00 UTC - last change
# Date: 2025-05-14 11:00 UTC - last change

export ED=${ED:-$INSTALL_DIR}

local X

test "X${USER}" != 'Xroot' || return 0

archdepdir(){
  for F in ${1}/*; do
    case ${F} in */*.so|*/*.a) return 0;; esac
  done
  return 1
}

cd ${ED}/ || return

if test -d "usr/local/bin" && emptydir "bin"; then
  mv -n usr/local/bin/* -t bin/ &&
  printf %s\\n 'mv -vn usr/local/bin/* bin/' ||
  printf %s\\n 'mv -vn usr/local/bin/* bin/... Error'
elif test -d "usr/bin" && emptydir "bin"; then
  mv -n usr/bin/* -t bin/ &&
  printf %s\\n 'mv -vn usr/bin/* bin/' ||
  printf %s\\n 'mv -vn usr/bin/* bin/... Error'
elif test -d "opt/diet/bin" && emptydir "bin"; then
  mv -n opt/diet/bin/* -t bin/ &&
  printf %s\\n 'mv -vn opt/diet/bin/* bin/' ||
  printf %s\\n 'mv -vn opt/diet/bin/* bin/... Error'
fi
if test -d "usr/local/sbin" && emptydir "sbin"; then
  mv -n usr/local/sbin/* -t sbin/ &&
  printf %s\\n 'mv -vn usr/local/sbin/* sbin/' ||
  printf %s\\n 'mv -vn usr/local/sbin/* sbin/... Error'
elif test -d "usr/sbin" && emptydir "sbin"; then
  mv -n usr/sbin/* -t sbin/ &&
  printf %s\\n 'mv -vn usr/sbin/* sbin/' ||
  printf %s\\n 'mv -vn usr/sbin/* sbin/... Error'
elif test -d "opt/diet/sbin" && emptydir "sbin"; then
  mv -n opt/diet/sbin/* -t sbin/ &&
  printf %s\\n 'mv -vn opt/diet/sbin/* sbin/' ||
  printf %s\\n 'mv -vn opt/diet/sbin/* sbin/... Error'
fi

if test -d "$(get_libdir)"; then
  for X in "$(get_libdir)/pkgconfig/"*.pc; do
    test -e "${X}" || break

    # FIX: for <includedir=//usr/include>
    sed -e '/^libdir=/ s|//|/|' -e '/^includedir=/ s|//|/|' -i ${X}

    {
      grep -q '^prefix=/$' < ${X} ||
      grep -q '^includedir=${prefix}/usr' < ${X} ||
      grep -q -v "^libdir=/$(get_libdir)" < ${X} ||
      grep -q '^datarootdir=${prefix}/share' < ${X} ||
      grep -q '^sysconfdir=${prefix}/etc' < ${X}
    } || continue
    sed \
      -e '1,10s|^prefix=/$|prefix=|;t' \
      -e "2,10s|^libdir=.*/lib$|libdir=/$(get_libdir)|;t" \
      -e "2,10s|^libdir=\${prefix}/$(get_libdir)$|libdir=/$(get_libdir)|;t" \
      -e '3,15s|^includedir=${prefix}/include$|includedir=/usr/include|;t' \
      -e '3,15s|^includedir=${prefix}/usr/include$|includedir=/usr/include|;t' \
      -e '4,20s|^bindir=${prefix}/bin$|bindir=/bin|;t' \
      -e '4,20s|^datarootdir=${prefix}/share$|datarootdir=/usr/share|;t' \
      -e '4,20s|^datadir=${prefix}/usr/share$|datadir=/usr/share|;t' \
      -e '5,20s|^sysconfdir=${prefix}/etc$|sysconfdir=/etc|;t' \
      -i ${X}
    printf %s\\n "sed s/libdir=.*/libdir=/$(get_libdir)/ -i ${X}"
  done
fi
if test ! -d "$(get_libdir)" && test -d "lib" && archdepdir "lib"; then
  mv -n lib $(get_libdir) && printf %s\\n 'mv -vn lib $(get_libdir)'
  for X in "$(get_libdir)/pkgconfig/"*.pc; do
    test -e "${X}" || break
    sed -i "3,10s|^libdir=.*/lib$|libdir=/$(get_libdir)|;t" ${X}
  done
fi
if test ! -d "usr/include" && test -d "include"; then
  mv -n include usr/ && printf %s\\n 'mv -vn include usr/include'
  for X in "$(get_libdir)/pkgconfig/"*.pc; do
    test -e "${X}" || break

    grep -q '^prefix=$' < ${X} &&
    sed -e '/^includedir=${prefix}/ s|${prefix}|/usr|g' -i ${X}

    sed \
      -e '4,15s|^includedir=.*/include$|includedir=/usr/include|;t' \
      -e '4,15s|^includedir=.*/include:|includedir=/usr/include:|;t' \
      -i ${X}

    #-e '/^includedir=${prefix}\/include/ s/\(=\|:\)${prefix}\/include\(:\|$\)/\1\/usr\/include\2/g' \
    #-e '/^includedir=${prefix}\/include/ s/\(=\|:\)${prefix}\/include\(\/\|$\)/\1\/usr\/include\2/g' \
    # testing-20241004
    #grep -q '^prefix=$' < ${X} &&
    #grep -q '^includedir=${prefix}/include' < ${X} &&
    #sed -e '3,15s/\(=\|:\)${prefix}\/include\(\/\|$\)/\1\/usr\/include\2/g;t' -i ${X}
    ##sed -e '3,15s/\(=\|:\)${prefix}\/include\(:\)/\1\/usr\/include\2/g;t' -i ${X}
  done
fi
