# bugfix: libdaemon fails to build with musl
#  testd.c: fatal error: sys/unistd.h: No such file
MYCONF="${MYCONF}
 --disable-examples
"
