#######  x32-bug: uint64_t * 1000000000000000000ULL  #######
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c: In function '_c32_qget_u64':
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c:1410:13: warning: this statement may fall through [-Wimplicit-fallthrough=]
 1410 |         ret += (uint64_t)tmp_data[2] * 1000000000000000000ULL;
      |         ~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c:1411:5: note: here
 1411 |     case 2:
      |     ^~~~
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c:1412:13: warning: this statement may fall through [-Wimplicit-fallthrough=]
 1412 |         ret += (uint64_t)tmp_data[1] * 1000000000ULL;
      |         ~~~~^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c:1413:5: note: here
 1413 |     case 1:
      |     ^~~~
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c: In function '_mpd_qdivmod.isra.0':
/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.c:8408:1: warning: '/build/Python-src/build/temp.linux-x86_64-3.6/build/Python-src/Modules/_decimal/libmpdec/mpdecimal.gcda' profile count data file not found [-Wmissing-profile]
##############################################################