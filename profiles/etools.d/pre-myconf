#!/bin/sh
# 2023-2025
# Date: 2024-05-03 21:00 UTC - last change
# Date: 2024-10-04 09:00 UTC - last change

export EPREFIX=${EPREFIX:-$SPREFIX}

CFLAGS=
CXXFLAGS=
#CPPFLAGS=
FFLAGS=
FCFLAGS=
LDFLAGS=

. "${PDIR%/}/etools.d/"build-functions

case $(tc-abi-build) in
  'x32')   append-flags -mx32 -msse2 ;;
  'x86')   append-flags -m32         ;;
  'amd64') append-flags -m64 -msse2  ;;
esac
if use 'static' || use 'static-libs'; then
  if use !shared; then
    append-flags -Os
    append-ldflags -Wl,--gc-sections
    append-cflags -ffunction-sections -fdata-sections
  fi

  if use 'shared' && use 'static'; then
    append-ldflags "--static"
  elif use 'static'; then
    append-ldflags "-s -static --static"
    # e.g: usr/ports/media-gfx/fbi/build-script.sh
    # BUG: undefined reference to `XML_GetCurrentLineNumber
    # FIX: static build with fontconfig - 2025.04.17
    #[ -x "/$(get_libdir)/libfontconfig.so" ] && append-ldflags -lexpat
    #check-pkg 'media-libs/fontconfig' && append-ldflags -lexpat
  fi
else
  use 'static-libgcc' && {
  append-cflags "-static-libgcc"
  append-cxxflags "-static-libgcc -static-libstdc++"
  }
  append-flags -O2
fi
append-flags -fno-stack-protector $(usex 'nopie' -no-pie) -g0 -march=$(arch | sed 's/_/-/')

if use 'lfs' || use 'largefile'; then
  # Add flags that enable Large File Support. (required for support-musl fix)
  CPPFLAGS="${CPPFLAGS}${CPPFLAGS:+ }-D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE"
fi

if use 'diet'; then
  PATH="${PATH:+${PATH}:}/opt/diet/bin"
  CC="$(usex diet 'diet -Os gcc -nostdinc')"
  CPP="$(usex diet 'diet -Os gcc -nostdinc -E')"  # bugfix: error: C preprocessor `gcc -E` fails sanity check
  CXX="g++$(usex static ' -static --static')"  # it really required?
elif use 'shared' && use 'static'; then
  CC="gcc --static"
  CXX="g++ --static"
  CC="gcc"
  CXX="g++"
else
  CC="gcc$(usex static ' -static --static')"
  CXX="g++$(usex static ' -static --static')"
fi

# testing (arch-dep): --exec-prefix=${EPREFIX}
# testing replace: --host=$(tc-chost)  -->  $(usex !diet --host=$(tc-chost) )
# configure
MYCONF="${MYCONF}
  --prefix=${EPREFIX}
  --exec-prefix=${EPREFIX}
  --bindir=${EPREFIX%/}/bin
  --sbindir=${EPREFIX%/}/sbin
  --libdir=${EPREFIX%/}/$(get_libdir)
  --includedir=${INCDIR}
  --libexecdir=${DPREFIX}/libexec
  --datadir=${DPREFIX}/share
"

# x86_64-pc-linux-dietlibcx32
# x86_64-linux-muslx32 -> x86_64-pc-linux-dietlibcx32 -> x86_64-pc-linux-gnux32
if use 'diet'; then
  MYCONF="${MYCONF}
  $(usex diet --host=$(tc-chost | sed 's/-/-pc-/;s/-musl/-dietlibc/') )
  $(usex diet --build=$(tc-chost | sed 's/-/-pc-/;s/-musl/-dietlibc/') )
"
#  MYCONF="${MYCONF}
#  $(usex diet --host=$(tc-chost | sed 's/-dietlibc/-gnu/') )
#  $(usex diet --build=$(tc-chost | sed 's/-dietlibc/-gnu/') )
#"
# x86_64-pc-linux-gnux32
# x86_64-pc-linux-muslx32
# x86_64-linux-muslx32
elif use 'musl'; then
  MYCONF="${MYCONF}
  $(usex !diet --host=$(tc-chost) )
  $(usex !diet --build=$(tc-chost) )
"
fi

# cmake
CMAKEFLAGS="${CMAKEFLAGS}
  -DCMAKE_INSTALL_PREFIX=''
  -DCMAKE_INSTALL_BINDIR='bin'
  -DCMAKE_INSTALL_SBINDIR='sbin'
  -DCMAKE_INSTALL_LIBDIR=$(get_libdir)
  -DCMAKE_INSTALL_INCLUDEDIR=${INCDIR}
  -DCMAKE_INSTALL_LIBEXECDIR=${DPREFIX}/libexec
  -DCMAKE_INSTALL_DATAROOTDIR=${DPREFIX}/share
  -DSTATIC_ONLY=$(usex 'shared' OFF ON)
  -DSHARED_ONLY=$(usex 'static-libs' OFF ON)
  -DBUILD_SHARED_LIBS=$(usex 'shared' ON OFF)
  -DBUILD_STATIC_LIBS=$(usex 'static-libs' ON OFF)
  -DCMAKE_SKIP_RPATH=$(usex 'rpath' OFF ON)
  -DWITH_NLS=$(usex 'nls' ON OFF)
  -DENABLE_NLS=$(usex 'nls' ON OFF)
  -DCMAKE_BUILD_TYPE='Release'
  -Wno-dev
"

# meson
MESON_FLAGS="${MESON_FLAGS}
  --prefix ${EPREFIX}
  --bindir bin
  --sbindir sbin
  --sysconfdir etc
  --libdir $(get_libdir)
  --includedir usr/include
  --libexecdir usr/libexec
  --datadir usr/share
  --localstatedir var/lib
  --wrap-mode nodownload
  --buildtype "release"  # testing 20241004
  $(usex 'strip' --strip)  # testing 20241004
"
