test "X${USER}" != 'Xroot' || return 0

MYCONF=$(mapsetre '--disable-static' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-shared' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-rpath' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-nls' '' ${MYCONF})

MYCONF="${MYCONF}
 --prefix=/
 --without-bmp
 --without-libungif
 --without-libpng
"
