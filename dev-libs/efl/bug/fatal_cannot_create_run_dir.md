------------
 efl-1.21.1
------------

================================================================================================================
  CCLD     lib/ecore_input_evas/libecore_input_evas.la
  CCLD     lib/ecore_imf_evas/libecore_imf_evas.la
  CCLD     lib/emotion/libemotion.la
libtool: warning: '/libx32/gcc/x86_64-linux-muslx32/9.5.0/../../../../libx32/libfontconfig.la' seems to be moved
libtool: warning: '/libx32/gcc/x86_64-linux-muslx32/9.5.0/../../../../libx32/libfreetype.la' seems to be moved
libtool: warning: '/libx32/gcc/x86_64-linux-muslx32/9.5.0/../../../../libx32/libfontconfig.la' seems to be moved
libtool: warning: '/libx32/gcc/x86_64-linux-muslx32/9.5.0/../../../../libx32/libstdc++.la' seems to be moved
================================================================================================================

==========================================================================
  CCLD     bin/edje/edje_pick
  CCLD     bin/edje/edje_watch
  CCLD     bin/ethumb/ethumb
  EDJ      modules/ethumb/emotion/template.edj
FATAL: Cannot create run dir '/root/.run' - errno=2
make[4]: *** [Makefile:57581: modules/ethumb/emotion/template.edj] Aborted
make[4]: *** Waiting for unfinished jobs....
==========================================================================


||||||||||||
|  bugfix  |
||||||||||||

===========================================================================================
| bug: User <build> have for homedir variable define: HOME=/root, it wrong.               |
| fix: HOME=${WORKDIR} - change dir to have permission for owner <rwx> (read,write,exec). |
===========================================================================================