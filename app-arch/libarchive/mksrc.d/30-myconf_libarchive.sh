# -static -static-libs +shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Multi-format archive and compression library"
HOMEPAGE="https://www.libarchive.org/ https://github.com/libarchive/libarchive/"
LICENSE="BSD BSD-2 BSD-4 public-domain"
IUSE="-acl -blake2 -bzip2 -e2fsprogs -expat +iconv -lz4 -lzma"
IUSE="${IUSE} -lzo -nettle -static-libs -test -xattr -zstd"
IUSE="${IUSE} -zcat -cpio -unzip"

export ac_cv_header_ext2fs_ext2_fs_h=$(usex 'e2fsprogs')  #354923

MYCONF="${MYCONF}
 $(use_enable 'zcat' bsdcat)
 $(use_enable 'cpio' bsdcpio)
 $(use_enable 'unzip' bsdunzip)
 --enable-bsdtar=shared
 --disable-posix-regex-lib
 $(use_enable 'acl')
 $(use_enable 'xattr')
 $(use_with 'blake2' libb2)
 $(use_with 'bzip2' bz2lib)
 $(use_with 'expat')
 #$(use_with !expat xml2)
 --without-xml2
 $(use_with 'iconv')
 $(use_with 'lz4')
 $(use_with 'lzma')
 $(use_with 'lzo' lzo2)
 $(use_with 'nettle')
 $(use_with 'zlib')
 $(use_with 'zstd')
 --without-cng
"
