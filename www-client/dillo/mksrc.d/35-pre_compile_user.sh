#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

# default link: -lfltk -lXrender -lXcursor -lXfixes -lXext -lXft -lfontconfig -lpthread -lX11
# default link: -lz -lpthread -lX11 -lmbedtls -lmbedx509 -lmbedcrypto

if use 'static'; then
  sed -e '/^LIBS =/ s/$/-lexpat -lxcb -lfreetype -lXau -lXdmcp -lXrender -lXft/' -i Makefile */Makefile
fi
