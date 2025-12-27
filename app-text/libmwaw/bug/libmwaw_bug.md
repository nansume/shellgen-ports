app-text/libmwaw-0.3.22 - error: final link failed: bad value
===============================================================================================================
  CXX      xattr.o
  CXX      zip.o
  CXXLD    mwawZip
make[4]: Leaving directory '/build/libmwaw-src/src/tools/zip'
make[4]: Entering directory '/build/libmwaw-src/src/tools'
make[4]: Nothing to be done for 'all-am'.
make[4]: Leaving directory '/build/libmwaw-src/src/tools'
make[3]: Leaving directory '/build/libmwaw-src/src/tools'
Making all in conv
make[3]: Entering directory '/build/libmwaw-src/src/conv'
Making all in helper
make[4]: Entering directory '/build/libmwaw-src/src/conv/helper'
  CXX      libconvHelper_la-helper.lo
  CXXLD    libconvHelper.la
make[4]: Leaving directory '/build/libmwaw-src/src/conv/helper'
Making all in csv
make[4]: Entering directory '/build/libmwaw-src/src/conv/csv'
  CXX      mwaw2csv.o
  CXXLD    mwaw2csv
/bin/ld: .libs/mwaw2csv: hidden symbol `main' in mwaw2csv.o is referenced by DSO
/bin/ld: final link failed: bad value
collect2: error: ld returned 1 exit status
make[4]: *** [Makefile:451: mwaw2csv] Error 1
-----------------
Failed make build
===============================================================================================================

Fix build:
-------------------------------------------
add: --disable-tools in ./configure ${opts}
-------------------------------------------