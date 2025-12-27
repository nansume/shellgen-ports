app-text/libabw-0.1.3 - error: final link failed: bad value
===============================================================================================================
  CXX      ABWXMLTokenMap.lo
  CXX      ABWZlibStream.lo
  CXX      AbiDocument.lo
  CXX      libabw_internal.lo
  CXXLD    libabw-0.1.la
make[4]: Leaving directory '/build/libabw-src/src/lib'
make[3]: Leaving directory '/build/libabw-src/src/lib'
Making all in conv
make[3]: Entering directory '/build/libabw-src/src/conv'
Making all in raw
make[4]: Entering directory '/build/libabw-src/src/conv/raw'
  CXX      abw2raw.o
  CXXLD    abw2raw
/bin/ld: .libs/abw2raw: hidden symbol `main' in abw2raw.o is referenced by DSO
/bin/ld: final link failed: bad value
collect2: error: ld returned 1 exit status
make[4]: *** [Makefile:448: abw2raw] Error 1
make[4]: Leaving directory '/build/libabw-src/src/conv/raw'
make[3]: *** [Makefile:385: all-recursive] Error 1
make[3]: Leaving directory '/build/libabw-src/src/conv'
make[2]: *** [Makefile:387: all-recursive] Error 1
make[2]: Leaving directory '/build/libabw-src/src'
make[1]: *** [Makefile:496: all-recursive] Error 1
make[1]: Leaving directory '/build/libabw-src'
make: *** [Makefile:407: all] Error 2
-----------------
Failed make build
===============================================================================================================

---------------------------------------------------------------------------------------------------------------
it no work:
===============================================================================================================
  CFLAGS=${CFLAGS/-no-pie }
  CXXFLAGS=${CXXFLAGS/-no-pie }
  FCFLAGS=${FCFLAGS/-no-pie }
  FFLAGS=${FFLAGS/-no-pie }
---------------------------
and then
---------------------------
  CC="gcc --static"
  CXX="g++ --static"
---------------------------
and then
---------------------------
  CFLAGS=${CFLAGS/-g* }
  CXXFLAGS=${CXXFLAGS/-g* }
  FCFLAGS=${FCFLAGS/-g* }
  FFLAGS=${FFLAGS/-g* }
===============================================================================================================