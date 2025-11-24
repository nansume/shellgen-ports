#!/bin/sh

MYCONF="${MYCONF}
 --disable-asciidoc
 --with-default-luks-format=LUKS2
 --enable-static-cryptsetup
 --disable-ssh-token
"