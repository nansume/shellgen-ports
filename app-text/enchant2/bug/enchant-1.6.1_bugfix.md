app-text/enchant-1.6.1 - buggy fix
==================================================================================
==================================================================================
enchant.c: In function 'enchant_get_version':
<command-line>: warning: return discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
enchant.c:2367:9: note: in expansion of macro 'ENCHANT_VERSION_STRING'
 2367 |  return ENCHANT_VERSION_STRING;
      |         ^~~~~~~~~~~~~~~~~~~~~~
  OBJCLD   libenchant.la
libtool: link: unable to infer tagged configuration
libtool:   error: specify a tag with '--tag'
make[2]: *** [Makefile:536: libenchant.la] Error 1
make[2]: Leaving directory '/build/enchant-src/src'
make[1]: *** [Makefile:630: all-recursive] Error 1
make[1]: Leaving directory '/build/enchant-src/src'
make: *** [Makefile:504: all-recursive] Error 1
Failed make build
==================================================================================

# Tags (Libtool)
https://www.gnu.org/software/libtool/manual/html_node/Tags.html
# c - Libtool: link: unable to infer tagged configuration
https://stackoverflow.com/questions/30369715/
==================================================================================
fixbug: patching - enchant-1.6.1-fix-clang-build.patch
==================================================================================


==================================================================================
ld: final link failed: bad value
collect2: error: ld returned 1 exit status
==================================================================================

fixbug:
==================================================================================
find ${EROOT}/${LIB_DIR}/ -name *${PN}.la -delete
find ${EROOT}/${LIB_DIR}/ -name ${PN}-*/*.la -delete
==================================================================================