#MAKEINSTALL+=" BIN=${INSTALL_DIR}/bin/${PN}  # no bindir --> bin file
#MAKEFLAGS=${MAKEFLAGS/ BIN=$INSTALL_DIR\/bin / }  # no bindir --> bin file

MAKEFLAGS=$(mapsetre 'BIN=*' '' ${MAKEFLAGS})  # otherwise compile instead install
