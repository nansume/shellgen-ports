no support x32
no build
incompatible asm (no x32)

####################################
making all in crypto/bn...
In file included from bn_div.c:60:
bn_div.c: In function 'BN_div':
../../include/openssl/bn.h:190:27: warning: conversion from 'long long unsigned int' to 'long unsigned int' changes value from '18446744073709551615' to '4294967295' [-Woverflow]
  190 | #  define BN_MASK2        (0xffffffffffffffffL)


####################################
# bug openssl: -march=x86_64 - novalid
#CFLAGS+= -O2 -march=$HOSTTYPE -pipe -g0"

# fix
CFLAGS+=" -march=${HOSTTYPE/_/-}"