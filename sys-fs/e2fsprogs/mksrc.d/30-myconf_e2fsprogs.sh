MYCONF="${MYCONF}
 #--enable-fuse
 --enable-elf-shlibs
 $(use 'musl' && printf '--enable-largefile')
 --disable-debugfs
 --disable-defrag
 --disable-e2initrd-helper
 --disable-fsck
 --disable-imager
 --disable-libblkid
 --disable-libuuid
 --disable-resizer
 --disable-testio-debug
 --disable-uuidd
"

# needed for >=musl-1.2.4, bug 908892
use 'musl' && append-cflags -D_FILE_OFFSET_BITS=64
