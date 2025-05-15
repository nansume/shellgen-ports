test "x${USER}" != 'xroot' || return 0

MYCONF="${MYCONF}
 $(use_with "fbcon" "fb")
 $(use_with "directfb")
 $(use_with "svga" "svgalib")
 $(use_with "x")
 $(use_enable "fbcon" "graphics")
 $(use_enable "fbcon" "utf8")
 $(use_with "fbcon" "gpm")
 $(use_with "ssl")
 #--with-ssl=${SPREFIX%/}/${LIB_DIR}
 $(use_with "ipv6")
 $(use_with "libevent")
 $(use_with "fbcon" "zlib")
 $(use_with "brotli")
 $(use_with "zstd")
 $(use_with "bzip2")
 $(use_with "xz" "lzma")
 $(use_with "lzip")
 $(use_with "fbcon" "freetype")
 $(use_with "fbcon" "libjpeg")
 $(use_with "fbcon" "libtiff")
 $(use_with "svg" "librsvg")
 $(use_with "fbcon" "libwebp")
 $(use_with "avif" "libavif")
"
#export OPENSSL_CFLAGS="-I${INCDIR}
#export OPENSSL_LIBS="-L${SPREFIX%/}/${LIB_DIR} -lssl -lcrypto

# fix: build fail
mv -n 'configure'.in 'configure'.ac
#autoupdate  # You should run autoupdate.
autoheader
autoconf
