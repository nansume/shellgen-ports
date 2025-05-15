# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Qt Cryptographic Architecture (QCA)"
HOMEPAGE="https://userbase.kde.org/QCA"
LICENSE="LGPL-2.1"
IUSE="-botan -debug -doc -examples +gcrypt -gpg -libressl -logger -nss -pkcs11 +qt4 -qt5 -sasl -softstore -ssl -test"

qca_plugin_use() {
  printf -DWITH_${2:-$1}_PLUGIN=$(usex "$1")
}

CMAKEFLAGS="${CMAKEFLAGS}
 -DCMAKE_CXX_STANDARD='14'
 -DBUILD_TESTS=$(usex 'test' ON OFF)
 -DWITH_NLS=$(usex 'nls' ON OFF)
 -DQT4_BUILD=ON
 $(qca_plugin_use ssl ossl)
"
