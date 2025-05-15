####  f34e584d5323f8a3379a4cc5528354460d99db78f63fe7e35555b94917f8757d  citadel.tar.gz

http://easyinstall.citadel.org/citadel.tar.gz
==============================================

deps: <bdb>, <curl>, <expat>, <ldap>, <libcitadel>, <libical>, <libressl>

#######  no build - fatal error: libreadline.so: undefined reference  #######
+ ./configure --bindir=/bin --sbindir=/sbin --includedir=/usr/include --libexecdir=/usr/libexec --datarootdir=/usr/share --host=x86_64-pc-linux-gnux32 --build=x86_64-pc-linux-gnux32 --disable-static --enable-shared

Running the configure script to create config.mk

./configure : unknown option --bindir

Valid options are:
  --ctdldir=DIR   Install Citadel server to DIR [/usr/local/citadel]
^[[1;32m +^[[1;36m /mksrc.d/36-pkg_compile.sh^[[m... ^[[1;33mrun^[[m
declare -x PWD="/build/citadel-src"
declare -- WORKDIR="/build/citadel-src"
+ nice -n 19 make --jobs=4 --load-average=4 -s V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `PC'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tgetflag'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tgetent'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `UP'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tputs'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tgoto'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tgetnum'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `BC'
/bin/ld: /libx32/gcc/x86_64-pc-linux-gnux32/9.1.0/../../../../libx32/libreadline.so: undefined reference to `tgetstr'
collect2: error: ld returned 1 exit status
make: *** [Makefile:28: ctdlmigrate] Error 1
####################################################