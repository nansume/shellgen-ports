==================================================================================================================
net-analyzer/openbsd-netcat-1.226 - build static: Failed.
==================================================================================================================
cc -static --static -mx32 -msse2 -Os -ffunction-sections -fdata-sections -fno-stack-protector -no-pie -g0 -march=x86-64
-I/build/netcat-openbsd-1.226/libmd/usr/include -I/build/netcat-openbsd-1.226/libbsd/usr/include -Wl,--gc-sections -s -static --static -L/build/netcat-openbsd-1.226/libmd/libx32 -L/build/netcat-openbsd-1.226/libbsd/libx32 netcat.o atomicio.o socks.o compat/base64.o -lmd -lbsd -lresolv -o nc
/bin/ld: /build/netcat-openbsd-1.226/libbsd/libx32/libbsd.a(getentropy.o): in function `getentropy_phdr':
getentropy.c:(.text.getentropy_phdr+0xd): undefined reference to `SHA512Update'
/bin/ld: /build/netcat-openbsd-1.226/libbsd/libx32/libbsd.a(getentropy.o): in function `getentropy_fallback':
getentropy.c:(.text.getentropy_fallback+0x8d): undefined reference to `SHA512Init'
/bin/ld: getentropy.c:(.text.getentropy_fallback+0xcb): undefined reference to `SHA512Update'
/bin/ld: getentropy.c:(.text.getentropy_fallback+0x12d): undefined reference to `SHA512Update'
/bin/ld: getentropy.c:(.text.getentropy_fallback+0x153): undefined reference to `SHA512Update'
/bin/ld: getentropy.c:(.text.getentropy_fallback+0x177): undefined reference to `SHA512Update'
/bin/ld: getentropy.c:(.text.getentropy_fallback+0x197): undefined reference to `SHA512Update'
/bin/ld: /build/netcat-openbsd-1.226/libbsd/libx32/libbsd.a(getentropy.o):getentropy.c:(.text.getentropy_fallback+0x1b9): more undefined references to `SHA512Update' follow
/bin/ld: /build/netcat-openbsd-1.226/libbsd/libx32/libbsd.a(getentropy.o): in function `getentropy_fallback':
getentropy.c:(.text.getentropy_fallback+0x822): undefined reference to `SHA512Final'
collect2: error: ld returned 1 exit status
make: *** [Makefile:14: nc] Error 1
==================================================================================================================