# elinks build options: --with-gnutls

gcc -DHAVE_CONFIG_H -I../.. -I../.././src -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -O3 -msse2 -fno-stack-protector -g0 -mx32 -march=x86-64 -ffast-math -Wall -fno-strict-aliasing -Wno-pointer-sign -Wno-address -fno-strict-overflow -o timer.o -c timer.c
gcc -DHAVE_CONFIG_H -I../.. -I../.././src -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -O3 -msse2 -fno-stack-protector -g0 -mx32 -march=x86-64 -ffast-math -Wall -fno-strict-aliasing -Wno-pointer-sign -Wno-address -fno-strict-overflow -o viewer.o -c viewer.c
ld -r -o lib.o action.o timer.o viewer.o  `test -e dump/lib.o && echo dump/lib.o`  `test -e text/lib.o && echo text/lib.o`
ld -r -o lib.o   `test -e bfu/lib.o && echo bfu/lib.o`  `test -e bookmarks/lib.o && echo bookmarks/lib.o`  `test -e cache/lib.o && echo cache/lib.o`  `test -e config/lib.o && echo config/lib.o`  `test -e cookies/lib.o && echo cookies/lib.o`  `test -e dialogs/lib.o && echo dialogs/lib.o`  `test -e document/lib.o && echo document/lib.o`  `test -e encoding/lib.o && echo encoding/lib.o`  `test -e formhist/lib.o && echo formhist/lib.o`  `test -e globhist/lib.o && echo globhist/lib.o`  `test -e intl/lib.o && echo intl/lib.o`  `test -e main/lib.o && echo main/lib.o`  `test -e mime/lib.o && echo mime/lib.o`  `test -e network/lib.o && echo network/lib.o`  `test -e osdep/lib.o && echo osdep/lib.o`  `test -e protocol/lib.o && echo protocol/lib.o`  `test -e session/lib.o && echo session/lib.o`  `test -e terminal/lib.o && echo terminal/lib.o`  `test -e util/lib.o && echo util/lib.o`  `test -e viewer/lib.o && echo viewer/lib.o`
gcc -DHAVE_CONFIG_H -I.. -I.././src -DBUILD_ID="\"\"" -O2 -msse2 -fno-stack-protector -g0 -march=x86-64 -O3 -msse2 -fno-stack-protector -g0 -mx32 -march=x86-64 -ffast-math -Wall -fno-strict-aliasing -Wno-pointer-sign -Wno-address -fno-strict-overflow -o vernum.o -c vernum.c
gcc -O3 -msse2 -fno-stack-protector -g0 -mx32 -march=x86-64 -ffast-math -Wall -fno-strict-aliasing -Wno-pointer-sign -Wno-address -fno-strict-overflow -rdynamic  -o elinks lib.o vernum.o -L/libx32 -lgcrypt -lgpg-error -lgnutls -ldl  -lz
/bin/ld: lib.o: in function `continue_download':
download.c:(.text+0x679f7): warning: the use of `tempnam' is dangerous, better use `mkstemp'
/bin/ld: lib.o: in function `done_gnutls':
ssl.c:(.text+0x518fd): undefined reference to `gnutls_anon_free_client_credentials'
/bin/ld: lib.o: in function `init_gnutls':
ssl.c:(.text+0x5193f): undefined reference to `gnutls_anon_allocate_client_credentials'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:41: elinks] Error 1
make: *** [Makefile.lib:268: all-recursive] Error 1