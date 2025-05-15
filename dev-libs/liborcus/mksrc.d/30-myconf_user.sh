# Maintainer: Artjom Slepnjov <shellgen@uncensored.citadel.org>
# -static -static-libs +shared -nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Standalone file import filter library for spreadsheet documents"
HOMEPAGE="https://gitlab.com/orcus/orcus/blob/master/README.md"
LICENSE="MIT"
IUSE="-python -spreadsheet-model -test +tools -nopie"

# FIX: ld: final link failed: bad value
CFLAGS=${CFLAGS/-no-pie }
CXXFLAGS=${CXXFLAGS/-no-pie }

MYCONF="${MYCONF}
 --disable-werror
 $(use_with 'tools')
 --disable-spreadsheet-model
 --disable-python
"
