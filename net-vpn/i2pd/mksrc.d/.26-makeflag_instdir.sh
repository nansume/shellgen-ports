SPREFIX=${SPREFIX}
# fix: the <usrdir> add for <timezone-data>
# fix: the <prefix> - test
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }PREFIX=${SPREFIX}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }prefix=${SPREFIX}"
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }USRDIR=${SPREFIX}"
