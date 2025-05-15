# bug: GCC 7.1.0
#  +Bochs x86 PC emulator / Bugs /
#   +#1392 compilling error (gentoo gcc): 'uintptr_t' was not declared in this scope
#   +https://sourceforge.net/p/bochs/bugs/1392/
`sed -i 's|uintptr_t|int)(uint8_t *|' iodev/network/slirp/cksum.cc`


#CFLAGS=${CFLAGS/ -ftree-vectorize/}
#CFLAGS=${CFLAGS/ -g0/}
#CFLAGS=${CFLAGS/ -msse2/}
#CFLAGS=${CFLAGS/ -msse3/}
#CFLAGS+=' -Wno-deprecated-declarations -Wccp -Wdeprecated-declarations'
#CFLAGS+=' -fvisibility=hidden -Wall -std=c99 -Werror=implicit-function-declaration'
#CFLAGS+=' -Werror=missing-prototypes -fno-math-errno -fno-trapping-math'
#CFLAGS+=' -Wno-write-strings -Wno-conversion-null -Wno-deprecated -Wno-error'
#CFLAGS+=' -pedantic -pedantic-errors'
#CXXFLAGS=$CFLAGS
#CXXFLAGS+=' -std=c++03'