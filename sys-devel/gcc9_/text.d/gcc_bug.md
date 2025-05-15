Using built-in specs.
COLLECT_GCC=gcc
Target: x86_64-linux-muslx32
Configured with: ../src_gcc/configure --enable-languages=c,c++,fortran --with-abi=x32 CC='x86_64-linux-muslx32-gcc -static --static' CXX='x86_64-linux-muslx32-g++ -static --static' FC='x86_64-linux-muslx32-gfortran -static --static' CFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error' CXXFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error' FFLAGS='-g0 -O2 -fno-align-functions -fno-align-jumps -fno-align-loops -fno-align-labels -Wno-error' LDFLAGS='-s -static --static' --enable-default-pie --enable-static-pie --disable-cet --disable-bootstrap --disable-assembly --disable-werror --target=x86_64-linux-muslx32 --prefix= --libdir=/lib --disable-multilib --with-sysroot=/ --enable-tls --disable-libmudflap --disable-libsanitizer --disable-gnu-indirect-function --disable-libmpx --enable-initfini-array --enable-libstdcxx-time=rt --enable-deterministic-archives --enable-libstdcxx-time --enable-libquadmath --enable-libquadmath-support --disable-decimal-float --build=x86_64-pc-linux-musl --host=x86_64-linux-muslx32
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 11.2.1 20211120 (GCC)


#MAKEOPTS="-j2"
#CFLAGS="-O2 -msse3 -pipe -g0 ${ABI_CFLAGS}"
#CXXFLAGS=${CFLAGS}


#####################################################################
# gcc - configure: error: no usable dependency style found
#####################################################################
checking for locale.h... yes
checking for wchar.h... yes
checking for thread.h... no
checking for pthread.h... yes
checking for CHAR_BIT... yes
checking whether byte ordering is bigendian... no
checking how to run the C++ preprocessor... i686-pc-linux-gnu-g++ -std=gnu++98 -E
checking for unordered_map... no
checking for tr1/unordered_map... yes
checking for ext/hash_map... yes
checking dependency style of i686-pc-linux-gnu-g++ -std=gnu++98... none
configure: error: no usable dependency style found
make[2]: *** [Makefile:4313: configure-stage1-gcc] Error 1



#####################################################################
# gcc_8.3.0 - missing binary operator before token
#####################################################################
# What does the compiler error <<missing binary operator before token>> mean? - Stack Overflow
https://stackoverflow.com/questions/21338385/what-does-the-compiler-error-missing-binary-operator-before-token-mean

# Using the GNU Compiler Collection (GCC): C++ Dialect Options
https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html

# gcc9 option(longlong)
https://www.google.com/search?q=gcc9+option(longlong)&hl=en&lr=lang_en



#####################################################################
# gcc_8.4.0: -Wabi=11 to warn about changes from GCC 7
#####################################################################
cc1plus: warning: -Wabi won't warn about anything [-Wabi]
cc1plus: note: -Wabi warns about differences from the most up-to-date ABI, which is also used by default
cc1plus: note: use e.g. -Wabi=11 to warn about changes from GCC 7