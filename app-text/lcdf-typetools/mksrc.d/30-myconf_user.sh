# +static -static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Font utilities for eg manipulating OTF"
HOMEPAGE="https://lcdf.org/type/#typetools https://github.com/kohler/lcdf-typetools"
LICENSE="GPL-2+"
IUSE="-kpathsea"

MYCONF="${MYCONF}
 $(use_with 'kpathsea')
"
