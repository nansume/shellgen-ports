MYCONF="${MYCONF}
 --disable-clientids
 --enable-kdrive
 --disable-xnest
 --disable-xvfb
 #--disable-unix-transport
 --disable-tcp-transport
 --disable-local-transport
 --disable-glx  # required: mesalib
 --disable-dri  # required: mesalib
 --disable-dri2  # required: mesalib
 --disable-glamor  # required: mesalib
 --with-sha1=libmd
"
