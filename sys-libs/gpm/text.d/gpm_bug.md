################
# no build gpm #
################
old date

# fix bug
# sync - current date
date -s "2018-01-01T01:00"

##########################################################################################

checking whether gcc accepts -g... yes
checking for gcc option to enable C11 features... none needed
./configure: line 3697: AC_PROG_LIBTOOL: command not found
checking for a BSD-compatible install... /bin/install -c

fix: . spkg-dep libtool

##########################################################################################

install: can't stat '/usr/ports/gpm/build/gpm-src/doc/gpm.info': No such file or directory
make[1]: *** [Makefile:122: install] Error 1
make: *** [Makefile:77: do-install] Error 1

build... ok