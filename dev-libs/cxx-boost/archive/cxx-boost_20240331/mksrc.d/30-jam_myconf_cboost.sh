test -x "${WORKDIR}/bootstrap.sh" || return 0

use 'x32' && MYCONF="${MYCONF:+${MYCONF}${NL}}abi=${ABI}"

if use 'shared'; then
  MYCONF="${MYCONF:+${MYCONF}${NL}}link=shared"
elif use 'static-libs'; then
  MYCONF="${MYCONF:+${MYCONF}${NL}}link=static"
fi

MYCONF=$(mapsetre '--bindir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--sbindir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--libexecdir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--datarootdir=*' '' ${MYCONF})
MYCONF=$(mapsetre '--host=*' '' ${MYCONF})
MYCONF=$(mapsetre '--build=*' '' ${MYCONF})
MYCONF=$(mapsetre '--enable-static' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-static' '' ${MYCONF})
MYCONF=$(mapsetre '--enable-shared' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-rpath' '' ${MYCONF})
MYCONF=$(mapsetre '--disable-nls' '' ${MYCONF})
