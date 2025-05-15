#-Wno-unused-function -Wno-strict-prototypes -Wno-write-strings
#CFLAGS=${CFLAGS/ -ftree-vectorize}
#CXXFLAGS=${CXXFLAGS/ -ftree-vectorize}

MYCONF="${MYCONF}
 # tui client
 # add: transmission-cli --enable-cli
 #  compatible version: transmission-2.94
 --enable-cli
 #--without-inotify
 #--with-kqueue=no
 #--enable-nls=no
"
