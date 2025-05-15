####  build from zero libxcb-1.15 - not found <xproto.h> - error - build failed  ####

fatal error: xproto.h: No such file or directory - build failed
===============================================================

==================================================================================
build sequence (bugfix):

* 1) libxcb-1.1.93 - no required - include xproto.h (is source, exactly get there).
Required install zero (no update)

* 2) libxcb-1.15 - required - include xproto.h (is source, may be get there)
Required deps: <python3> otherwise to find - include/<xproto.h>
===================================================================================

successful!
===================================================================================