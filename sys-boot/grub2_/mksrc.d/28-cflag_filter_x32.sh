#26-cflag_filter_x32.sh

#CFLAGS=${CFLAGS/ -mx32}
CFLAGS=$(printf %s " ${CFLAGS} " | sed 's/ -mx32 / /')
#CXXFLAGS=${CXXFLAGS/ -mx32}

#CFLAGS=${CFLAGS/ -march=${HOSTTYPE/_/-}}
CFLAGS=$(printf %s "${CFLAGS}" | sed 's/ -march=[^ ]* / /;s/^ *//;s/ *$//')
#CPPFLAGS="${CPPFLAGS/ -march=${HOSTTYPE/_/-}}
#CXXFLAGS="${CXXFLAGS/ -march=${HOSTTYPE/_/-}}
#FCFLAGS="${FCFLAGS/ -march=${HOSTTYPE/_/-}}
#FFLAGS="${FFLAGS/ -march=${HOSTTYPE/_/-}}

#filter-flags -mx32 -m64