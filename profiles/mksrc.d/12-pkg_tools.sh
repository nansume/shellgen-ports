LC_ALL='C'
export MAKESYSPATH="/usr/share/mk/bmake"  # temporary fix, required change pkg bmake.
#export MAKEFLAGS="--jobs=$(nproc) --load-average=$(nproc) -s V=0"
export MAKEFLAGS="-j$(nproc) V=0"
#ABI=x32
#LIB_DIR=libx32
BUILD_USER='tools'
SRC_DIR='build'

# CFLAGS -ftree-vectorize -march=x86-64 -pipe
export CFLAGS='-O2 -msse2 -fno-stack-protector -g0'
export CPPFLAGS='-O2 -msse2 -fno-stack-protector -g0'
export CXXFLAGS='-O2 -msse2 -fno-stack-protector -g0'
export FCFLAGS='-O2 -msse2 -fno-stack-protector -g0'
export FFLAGS='-O2 -msse2 -fno-stack-protector -g0'

#MAKEINFO=/dev/null
#GCC_VER=9.1.0
#IONICE_COMM='ionice -c 3 nice -n 19
IONICE_COMM='nice -n 19'