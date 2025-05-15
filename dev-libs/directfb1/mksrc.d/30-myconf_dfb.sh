# https://git.alpinelinux.org/aports/plain/community/directfb/APKBUILD

#autoconf

MYCONF="${MYCONF}
 #--without-tools
 --with-inputdrivers=keyboard,ps2mouse
 --enable-bmp=no
 --disable-zlib
 $(use_enable 'debug' 'debug-support')
 --enable-devmem=$(usex 'devmem' yes no)
 --enable-multi-kernel=no
 --with-gfxdrivers=none
 --enable-gif=$(usex 'gif' yes no)
 --enable-jpeg2000=no
 --enable-linotype=no
 --enable-mpeg2=no
 $(use_enable 'net' 'network')
 --enable-pnm=no
 --without-setsockopt
 --enable-video4linux=no
"
