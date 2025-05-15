#!/bin/sh
# Copyright (C) 2023-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2024-04-19 20:00 UTC - last change
# required rename: 19-drop_ldconfig.sh --> 19-xutils_stub.sh

local X

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

printf '#!/bin/sh' > /bin/xutils-stub
chmod +x /bin/xutils-stub

if ! use 'ldconfig'; then
  for X in /[s]bin/ldconfig; do
    test -e "${X}" && rm -- "${X}"
  done
  ln -sf ../bin/xutils-stub /sbin/ldconfig
  printf %s\\n "ln -sf ../bin/xutils-stub /sbin/ldconfig"
fi

if use 'xstub'; then
  test -x "/bin/groff"     || ln -vsf xutils-stub /bin/groff
  test -x "/bin/gtkdocize" || ln -vsf xutils-stub /bin/gtkdocize
  test -x "/bin/help2man"  || ln -vsf xutils-stub /bin/help2man
  test -x "/bin/makeinfo"  || ln -vsf xutils-stub /bin/makeinfo
  test -x "/bin/msgfmt"    || ln -vsf xutils-stub /bin/msgfmt
  test -x "/bin/pod2html"  || ln -vsf xutils-stub /bin/pod2html
  test -x "/bin/pod2man"   || ln -vsf xutils-stub /bin/pod2man
  test -x "/bin/pod2text"  || ln -vsf xutils-stub /bin/pod2text
  test -x "/bin/python"    || ln -vsf xutils-stub /bin/python
  test -x "/bin/soelim"    || ln -vsf xutils-stub /bin/soelim
  test -x "/bin/xgettext"  || ln -vsf xutils-stub /bin/xgettext
  test -x "/bin/xsltproc"  || ln -vsf xutils-stub /bin/xsltproc
  test -x "/bin/xmlto"     || ln -vsf xutils-stub /bin/xmlto
fi

for X in /etc/ld.so[.]conf; do
  test -e "${X}" && chown ${BUILD_USER}:${BUILD_USER} "${X}"
done
