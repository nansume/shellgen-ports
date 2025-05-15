#!/bin/sh
# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

#inherit install-functions  # update to uncomment

DESCRIPTION="minimalistic commandline pastebin"
HOMEPAGE="https://bsd.ac"
LICENSE="ISC"
ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd "${ED}/" || return

mkdir -m 0755 -- "usr/share/${PN}/"
mv -n "usr/share/POSIX_shell_client.sh" "usr/share/paste.html" -t usr/share/${PN}/
#rm -- "usr/share/POSIX_shell_client.sh" "usr/share/paste.html"

#insinto /var/www/purritobin
#doins frontend/paste.html
#keepdir /var/db/purritobin
#fowners purritobin:purritobin /var/www/purritobin /var/db/purritobin
#einstalldocs

printf %s\\n "mv -n usr/share/<files> -t usr/share/${PN}/"
