# 

DESCRIPTION="C++ client library for the CMIS interface"
HOMEPAGE="https://github.com/tdf/libcmis"
LICENSE="|| ( GPL-2 LGPL-2 MPL-1.1 )"
IUSE="-man -test +tools"

MYCONF="${MYCONF}
 --disable-werror
 --without-man
 --disable-tests
 $(use_enable 'tools' client)
"
