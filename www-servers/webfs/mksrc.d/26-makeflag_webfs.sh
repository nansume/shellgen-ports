test "x${USER}" != 'xroot' || return 0

MAKEFLAGS=$(mapsetre 'prefix=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(mapsetre 'LIB=*' '' ${MAKEFLAGS})

MAKEFLAGS="${MAKEFLAGS}
 LIB=${LIB_DIR}
 USE_SSL=no
 prefix=${SPREFIX%/}/
 bindir=${INSTALL_DIR}/bin
"

#sed '/OBJS/ s|cgi.o|| -i GNUmakefile
#sed /*listen_port/ s|8000"|NULL|' -i webfsd.c
#sed /*cgipath/d' -i webfsd.c

#rm -- cgi.c
