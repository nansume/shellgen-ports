#!/bin/sh

tc_export() {
  while [ x"${1-}" != x ]; do
  case ${1} in
    'PKG_CONFIG')
      [ -n "${LIB_DIR:?}" ] || return
      export PKG_CONFIG="pkgconf"
      export PKG_CONFIG_LIBDIR="/${LIB_DIR}/pkgconfig"
      export PKG_CONFIG_PATH="${PKG_CONFIG_LIBDIR}:/lib/pkgconfig:/usr/share/pkgconfig"
    ;;
    'AR')
      export AR="ar"
    ;;
    'CC')
      export CC="cc"
    ;;
    'CXX')
      export CXX="c++"
    ;;
    'CPP')
      export CPP="gcc -E"
    ;;
    'LIBTOOL')
      export LIBTOOL="libtool"
    ;;
    'RANLIB')
      export RANLIB="ranlib"
    ;;
    'LD')
      if use 'x32'; then
        export LD="ld -m elf32_x86_64"
      else
        export LD="ld"
      fi
    ;;
  esac
  shift
  done
}

# hush - not implementation <alias> - replace to: func name no posix
if typeis 'alias' && [ -z "${BB_ASH_VERSION-}" ]; then
  alias tc-export='tc_export'
fi
# name func no-posix
if ! typeis 'alias' || [ -n "${BB_ASH_VERSION-}" ]; then
  tc-export() { tc_export $@;}
fi