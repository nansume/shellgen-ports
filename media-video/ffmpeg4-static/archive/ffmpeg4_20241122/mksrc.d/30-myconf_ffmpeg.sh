test "X${USER}" != 'Xroot' || return 0

MYCONF=$(printf %s "${MYCONF}" | sed 's/--includedir=/--incdir=/')
MYCONF=$(mapsetre '--build=*' '' ${MYCONF})
MYCONF=$(mapsetre '--host=*' '' ${MYCONF})
MYCONF=$(mapsetre '--exec-prefix=*' '' ${MYCONF})
MYCONF=$(mapsetre '--sbindir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--libexecdir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-nls' '' ${MYCONF})

MYCONF="
 --prefix=${EPREFIX%/}
 --bindir=${EPREFIX%/}/bin
 --libdir=${EPREFIX%/}/$(get_libdir)
 --incdir=${INCDIR}
 --datadir=${DPREFIX}/share
 --disable-static
 --enable-shared
 --disable-rpath
 --enable-gpl
 --enable-version3
 #--disable-programs  # comment it for yt-dlp
 --disable-encoders
 --disable-filters
 --disable-debug
 $(use_enable 'iconv')
 --disable-lzma
 --disable-zlib
 --disable-postproc
 --disable-indev=lavfi
 --disable-indev=oss
 --disable-indev=v4l2
 --disable-outdev=oss
 --disable-outdev=v4l2
"

# test big-endian or little-endian, required replace od --> xxd
# busybox nocompat: od: unrecognized option: t
sed -e 's|^\(od -t x1 \)|#\1|' -i configure
