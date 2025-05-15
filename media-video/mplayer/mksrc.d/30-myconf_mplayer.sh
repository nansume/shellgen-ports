# Static build with useflag: static +static-libs -shared -doc -xstub -diet +musl +x32

test "X${USER}" != 'Xroot' || return 0

MYCONF=$(mapsetre '--sbindir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--includedir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--libexecdir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--host=*' '' ${MYCONF})
MYCONF=$(mapsetre '--build=*' '' ${MYCONF})
MYCONF=$(mapsetre '--enable-shared' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-shared' '' ${MYCONF})
# ${MAKEFLAGS/LIBDIR=$LIBDIR/LIBDIR=$INSTALL_DIR$LIBDIR}
# ${MAKEFLAGS/ LIBDIR=$LIBDIR/}
MAKEFLAGS=$(mapsetre 'LIBDIR=*' '' ${MAKEFLAGS})

MYCONF="${MYCONF}
 --disable-mencoder
 --disable-tv
 --disable-pvr
 --disable-vcd
 #--disable-fbdev
 --disable-unrarexec
 --disable-sortsub
 --disable-dvb
 $(use_enable 'mp3' mpg123)  # enable mpg123 - testing
 --disable-real
 --disable-xanim
 --disable-qtx
 --disable-ossaudio
 --disable-v4l2
 --disable-tga
 --disable-png
 --disable-pnm
 --disable-jpeg
 --disable-md5sum
 --disable-yuv4mpeg
 --disable-ass
 --disable-ass-internal
 --disable-select
 --disable-sighandler
 --disable-postproc
 --disable-rtc
 --enable-iconv
 --charset=noconv
 --disable-3dnow
 --disable-ssse3
 --disable-avx
 --disable-fma3
"
