# https://github.com/archlinux/svntogit-packages/raw/packages/syslinux/trunk/PKGBUILD
#MAKEFLAGS+=" MAKEDIR=mk bios -f memdisk/Makefile
#MAKEFLAGS+=" MAKEDIR=mk bios -f ${PN}/Makefile
#MAKEFLAGS+=" bios installer
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}bios"
