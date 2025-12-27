==================================================================================================
Checking for availability of switch -std=gnu99 ... yes
Checking for availability of switch -std=c99 ... yes
Checking for availability of switch -Wextra ... yes
Checking function pthread_create in -lpthread ... yes
Checking presence of header file sys/soundcard.h ... no
Checking presence of header file soundcard.h ... no
Checking function _oss_ioctl in -lossaudio ... no
Checking function clock_gettime in -lrt ... yes
Checking function dnet_conn in -ldnet ... no

 ALSA:            yes
 OSS:             no
 libAO:           no
 PortAudio:       no
 JACK:            no
 Roar VS:         no
 OpenAL:          no
 muRoar:          no
 PulseAudio:      no
 libsamplerate:   yes
 syslog:          yes

 CC:     gcc
 CFLAGS: -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -std=gnu99 -Wall -Wextra

:: Type 'make' to compile ('gmake' for BSD systems).
Configure directory: /build/rsound-src/... ok
nice -n 19 make -j4 V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
==================================================================================================

Build:
==================================================================================================
rsound-common.c:168:20: note: length computed here
  168 |       char tmp_fmt[strlen(fmt) + 1];
      |                    ^~~~~~~~~~~
AR librsound/librsound.a
LD librsound/librsound.so.3.0.0
LD rsdplay
LD rsd
/bin/ld: /libx32/gcc/x86_64-linux-muslx32/9.5.0/../../../../libx32/crt1.o: in function `_start_c':
(.text._start_c+0x15): undefined reference to `main'
collect2: error: ld returned 1 exit status
make[1]: *** [Makefile:115: librsound/librsound.so.3.0.0] Error 1
make[1]: *** Waiting for unfinished jobs....
make[1]: Leaving directory '/build/rsound-src/src'
make: *** [Makefile:5: all] Error 2
==================================================================================================

# bugfix
CFLAGS=${CFLAGS/-no-pie }