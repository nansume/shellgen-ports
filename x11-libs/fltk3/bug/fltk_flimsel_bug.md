bug: if build with bundled-libs: libjpeg-turbo,libpng,zlib
==============================================
  CXX      workpool.o
  CXXLD    flimsel
/bin/ld: cannot find -lfltk_png
/bin/ld: cannot find -lfltk_z
/bin/ld: cannot find -lfltk_jpeg
collect2: error: ld returned 1 exit status
make[2]: *** [Makefile:356: flimsel] Error 1
==============================================

bugfix:
========================================================================================
x11-libs/fltk build temporary with system-libs: libjpeg-turbo,libpng,zlib for buildtime,
a runtime x11-libs/fltk bundled-libs: libjpeg-turbo,libpng,zlib.
========================================================================================