#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

#CC="cc -static-libgcc -static-libstdc++"
#CXX="c++ -static-libgcc -static-libstdc++"

sed \
  -e '/^CC = cc/d' \
  -e '/^CFLAGS/ s/=/+=/' \
  -e '/^LDFLAGS/ s/=/+=/' \
  -e '/_LDFLAGS/ s/=/+= -static-libgcc -static-libstdc++/' \
  -i Makefile