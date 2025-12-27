test "x${XPN}" = 'xlosetup' || return 0

MYCONF=$(mapsetre '--enable-shared' '--disable-shared' ${MYCONF})
MYCONF=$(mapsetre '--disable-static' '--enable-static' ${MYCONF})

MYCONF="${MYCONF}
 --enable-libsmartcols
 #--enable-static-programs=${XPN}
 --disable-blkid
 --disable-all-programs
"
