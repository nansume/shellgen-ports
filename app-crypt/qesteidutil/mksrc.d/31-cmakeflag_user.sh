# -static -static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Estonian ID card management desktop utility"
HOMEPAGE="https://github.com/open-eid/qesteidutil https://id.ee/"
LICENSE="LGPL-2.1"
IUSE="+webcheck (+musl) -xstub +stest +strip"

CMAKEFLAGS="${CMAKEFLAGS}
 -DBREAKPAD=NO
 -DCONFIG_URL='https://id.eesti.ee/config.json'
"
