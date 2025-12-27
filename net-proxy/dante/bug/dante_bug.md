=======================================================================================
#######  no build: <dante> any versions  #######
checking for errno symbol EWRPROTECT... no
checking errno symbols... unique symbols: 124, unique values: 1
checking for getaddrinfo() error EAI_ADDRFAMILY... no
checking for getaddrinfo() error EAI_AGAIN... OK
checking for getaddrinfo() error EAI_BADFLAGS... OK
checking for getaddrinfo() error EAI_BADHINTS... no
checking for getaddrinfo() error EAI_FAIL... OK
checking for getaddrinfo() error EAI_FAMILY... OK
checking for getaddrinfo() error EAI_MEMORY... OK
checking for getaddrinfo() error EAI_NODATA... no
checking for getaddrinfo() error EAI_NONAME... OK
checking for getaddrinfo() error EAI_OVERFLOW... OK
checking for getaddrinfo() error EAI_PROTOCOL... no
checking for getaddrinfo() error EAI_SERVICE... OK
checking for getaddrinfo() error EAI_SOCKTYPE... OK
checking for getaddrinfo() error EAI_SYSTEM... OK
checking for getaddrinfo() error EAI_ALLDONE... no
checking for getaddrinfo() error EAI_CANCELED... no
checking for getaddrinfo() error EAI_IDN_ENCODE... no
checking for getaddrinfo() error EAI_INPROGRESS... no
checking for getaddrinfo() error EAI_INTR... no
checking for getaddrinfo() error EAI_NOTCANCELED... no
checking for getaddrinfo() error EAI_BADEXTFLAGS... no
checking getaddrinfo() error symbols... configure: error: in `/build/dante-src':
configure: error: error: getaddrinfo() error value count too low
See `config.log' for more details
 + /mksrc.d/36-pkg_compile.sh... run
declare -x PWD="/build/dante-src"
=======================================================================================
fix: remove: export CBUILD CTARGET PKG_CONFIG_LIBDIR PKG_CONFIG_PATH CC CXX CPP LIBTOOL
fix: remove: . gen-variables
it fix?
=======================================================================================


====================================================================
bug: bindresvport: symbol not found
====================================================================
ldd /libx32/libsocks.so
  ldd (0xf7e99000)
  libc.so => ldd (0xf7e99000)
Error relocating /libx32/libsocks.so: bindresvport: symbol not found
====================================================================
fix: install: libaio libnsl libc6-compat ?
====================================================================


==================================================================
#--enable-preload
#--enable-clientdl
#--enable-serverdl
#--enable-drt-fallback
#--disable-serverdl
--disable-client
--enable-drt-fallback
--without-glibc-secure
#--without-bsdauth
#--without-full-env
#--without-gssapi
#--without-sasl
#--with-libc="libc.so.6"

#sed -e 's/-all-dynamic//' -i dlib/Makefile.am dlib64/Makefile.am
#sed -e 's:AM_CONFIG_HEADER:AC_CONFIG_HEADERS:' -i configure.ac
==================================================================


#41cd1edfbd9ca40c62fe71b63f5365884bda37c3b80baa03a098e470084c863d  dante-1.4.0-HAVE_SENDBUF_IOCTL.patch
#cacc63d0ef7d34856f38d1cf5aae58e2c5ec5884d3bfc9798737370ea9368dcb  dante-1.4.0-cflags.patch
#b4f2fc60661aa2bff934c2f49ec156359dbccb92a3c499c703f4c98283a95705  dante-1.4.0-osdep-format-macro.patch
#4ee5e22067ef6b3cd5bfaf1774bb19940e1ae8dda8dc8cce198789fc871ba7ba  dante-1.4.0-socksify.patch
#6ac365d0fd968a2e4f667a522cab842e1b88981a18a835e37bdd1d07f0bbf695  dante-1.4.1-miniupnp14.patch
#27ff872b9a58d13b63198aa98c031e7aa4ad7392cc5b56212fb5e4d118daa34c  dante-1.4.1-sigpwr-siginfo.patch
#dda522ddc44cb2aa15885a00471b6bf08b4070373e0b82dbeecb89f95be91cb8  0002-osdep-m4-Remove-getaddrinfo-too-low-checks.patch