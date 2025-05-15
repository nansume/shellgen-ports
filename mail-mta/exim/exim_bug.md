==================================================================================================================
mail-mta/exim-4.96 - error: invalid application of 'sizeof' to incomplete type 'struct options'
==================================================================================================================
+ nice -n 19 make -j4 V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
/bin/sh scripts/source_checks
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression

>>> Creating links to source files...
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
awk: bad regex '{ (US)?"': Repetition not preceded by valid expression
>>> Creating lookups/Makefile for building dynamic modules
>>> New Makefile & lookups/Makefile installed
>>> Use "make makefile" if you need to force rebuilding of the makefile

make[1]: warning: -j4 forced in submake: resetting jobserver mode.
make[1]: Entering directory '/build/exim-src/build-Linux-x86_64'
==================================================================================================================
cc sieve.c
cc smtp_in.c
cc smtp_out.c
smtp_in.c: In function 'smtp_start_session':
smtp_in.c:2677:36: error: invalid application of 'sizeof' to incomplete type 'struct options'
 2677 |     EXIM_SOCKLEN_T optlen = sizeof(struct ip_options) + MAX_IPOPTLEN;
      |                                    ^~~~~~
smtp_in.c:2724:35: error: dereferencing pointer to incomplete type 'struct options'
 2724 |       uschar *optstart = US (ipopt->__data);
      |                                   ^~
cc spool_in.c
make[1]: *** [Makefile:763: smtp_in.o] Error 1
make[1]: *** Waiting for unfinished jobs....
make[1]: Leaving directory '/build/exim-src/build-Linux-x86_64'
make: *** [Makefile:36: all] Error 2
==================================================================================================================