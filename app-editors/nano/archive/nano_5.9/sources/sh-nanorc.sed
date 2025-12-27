#!/bin/sed -f
#^usr/share/nano/sh.nanorc
# 2021

s|^\(syntax .*\)$|\1 "\\\.env\$"|
s|^\(syntax .*\)$|\1 "\\\.ipxe\$"|
s|^\(syntax .*\)$|\1 "\\\.[0-9]\$"|
/header/ s%\(runscript\)%ipxe|\1%
/header/ s|/||
10s|\(brightgreen ..\)|\1\[ \]\*|