# -static +static-libs +shared +nopie -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Library for SSA/ASS subtitles rendering"
HOMEPAGE="https://github.com/libass/libass"
LICENSE="ISC"
IUSE="+fontconfig -libunibreak -test"

MYCONF="${MYCONF}
 $(usex 'x32' --disable-asm)
 --enable-large-tiles
 --disable-require-system-font-provider
"
