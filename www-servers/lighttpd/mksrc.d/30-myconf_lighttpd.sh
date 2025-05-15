MYCONF=$(mapsetre '--libdir=*' "--libdir=${EPREFIX%/}/$(get_libdir)/${PN}" ${MYCONF})

MYCONF="${MYCONF} $(use_with zlib)"