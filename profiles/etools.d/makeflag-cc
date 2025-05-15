#!/bin/sh
# 2023-2024
# Date: 2024-05-02 21:00 UTC - fix: add CC,CXX flags in MAKEFLAGS

if use 'diet'; then
  PATH="${PATH:+${PATH}:}/opt/diet/bin"
  CC="$(usex diet 'diet -Os gcc -nostdinc')"
  CXX="g++$(usex static ' -static --static')"
  return  # testing
elif use 'static' || use 'static-libs'; then
  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"
  return  # testing
fi

if use 'static' || use 'diet'; then
                     test -n "${CC-}" && MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }CC=${CC}"
  { test -n "${CXX-}" && use !diet ;} && MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }CXX=${CXX}"
fi
