#!/bin/sh
# Copyright (C) 2024 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-11-01 17:00 UTC - last change

test "X${USER}" != 'Xroot' || return 0

test -x "/bin/qmake" && {
  export QMAKE="/bin/qmake"
  export QMAKE="qmake"
}

if test -x "/bin/qmake-qt4"; then
  test -x "/$(get_libdir)/qt4/bin/qmake" && export QMAKE="/$(get_libdir)/qt4/bin/qmake"
  if test -x "/$(get_libdir)/qt4/bin/qmake"; then
    export QTDIR="/$(get_libdir)/qt4/bin"
    export PATH="${PATH}${PATH:+:}/$(get_libdir)/qt4/bin"
  fi
  export QMAKE="qmake-qt4"
  test -d "/usr/share/qt4/mkspecs/linux-g++" && export QMAKESPEC="/usr/share/qt4/mkspecs/linux-g++"
elif test -x "/bin/qmake-qt5"; then
  test -x "/$(get_libdir)/qt5/bin/qmake" && export QMAKE="/$(get_libdir)/qt5/bin/qmake"
  if test -x "/$(get_libdir)/qt5/bin/qmake"; then
    export QTDIR="/$(get_libdir)/qt5/bin"
    export PATH="${PATH}${PATH:+:}/$(get_libdir)/qt5/bin"
  fi
  export QMAKE="qmake-qt5"
  test -d "/$(get_libdir)/qt5/mkspecs/linux-g++" && export QMAKESPEC="/$(get_libdir)/qt5/mkspecs/linux-g++"
else
  return 0
fi
#test -n ${QMAKE}" && export QMAKE=${QMAKE##*/}