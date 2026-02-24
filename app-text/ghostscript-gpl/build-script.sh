#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-17 21:00 UTC - last change
# Build with useflag: +static +static-libs +shared -lfs +nopie +patch -doc -xstub -diet +musl +stest +strip +x32

# http://data.gpo.zugaina.org/gentoo/app-text/ghostscript-gpl/ghostscript-gpl-10.03.0.ebuild

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="Interpreter for the PostScript language and PDF"
HOMEPAGE="https://ghostscript.com/ https://git.ghostscript.com/?p=ghostpdl.git;a=summary"
LICENSE="AGPL-3 CPL-1.0"
PN="ghostscript-gpl"
SPN="ghostscript"
PV="10.03.0"
SRC_URI="
  https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10030/${SPN}-${PV}.tar.gz
  https://dev.gentoo.org/~sam/distfiles/app-text/${PN}/${PN}-10.0-patches.tar.xz
  http://data.gpo.zugaina.org/gentoo/app-text/${PN}/files/${PN}-${PV}-c99.patch
"
IUSE="-cups -dbus -gtk -l10n_de +static-libs -unicode -X -doc -xstub"
IUSE="${IUSE} +static +shared -doc (+musl) +stest +strip"
TARGET_INST=
BUILD_DIR="${PDIR%/}/${SRC_DIR}/${SPN}-${PV}"
PROG="bin/gs"

pkgins() { pkginst \
  "app-text/libpaper" \
  "app-text/poppler-data" \
  "dev-build/autoconf71  # required for autotools" \
  "dev-build/automake16  # required for autotools" \
  "dev-build/libtool9  # required for autotools,libtoolize" \
  "dev-lang/perl  # required for autotools" \
  "dev-util/pkgconf" \
  "media-fonts/urw-fonts" \
  "sys-apps/file" \
  "sys-devel/binutils9" \
  "sys-devel/gcc9" \
  "sys-devel/lex  # alternative a flex (posix)" \
  "sys-devel/m4  # required for autotools" \
  "sys-devel/make" \
  "sys-libs/musl" \
  "#sys-libs/zlib" \
  || die "Failed install build pkg depend... error"
}

prepare(){
  case $(tc-abi-build) in
    'x32')   append-flags -mx32 -msse2            ;;
    'x86')   append-flags -m32 -msse -mfpmath=sse ;;
    'amd64') append-flags -m64 -msse2             ;;
  esac
  append-flags -O2 -DNDEBUG -fno-stack-protector -no-pie -g0 -march=$(arch | sed 's/_/-/')
}

build() {
  LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${ED}/$(get_libdir)"

  for F in ../${PN}-${PV%?.*}-patches/*".patch" ${FILESDIR}/*".patch"; do
    case ${F} in *'*'*) continue;; esac
    [ -f "${F}" ] && patch -p1 -E < "${F}"
  done

  # Remove internal CMaps (CMaps from poppler-data are used instead)
  rm -r -- Resource/CMap/ || die

  if use !gtk ; then
    sed \
      -e "s:\$(GSSOX)::" \
      -e "s:.*\$(GSSOX_XENAME)$::" \
      -i base/unix-dll.mak || die "sed failed"
  fi

  # Search path fix
  # put LDFLAGS after BINDIR, bug #383447
  sed \
    -e "s:\$\(gsdatadir\)/lib:@datarootdir@/ghostscript/${PV}/$(get_libdir):" \
    -e "s:exdir=.*:exdir=@datarootdir@/doc/${PN}/examples:" \
    -e "s:docdir=.*:docdir=@datarootdir@/doc/${PN}/html:" \
    -e "s:GS_DOCDIR=.*:GS_DOCDIR=@datarootdir@/doc/${PN}/html:" \
    -e 's:-L$(BINDIR):& $(LDFLAGS):g' \
    -i Makefile.in base/*.mak || die "sed failed"

  for path in \
      "${EPREFIX%/}"/usr/share/fonts/urw-fonts \
      "${EPREFIX%/}"/usr/share/fonts/Type1 \
      "${EPREFIX%/}"/usr/share/fonts
    do
    FONTPATH="${FONTPATH}${FONTPATH:+:}${EPREFIX}${path}"
  done

  ./configure \
    --prefix="/usr" \
    --exec-prefix="${EPREFIX%/}" \
    --bindir="${EPREFIX%/}/bin" \
    --sysconfdir="${EPREFIX%/}"/etc \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --datadir="${EPREFIX%/}"/usr/share \
    --mandir="${EPREFIX%/}"/usr/share/man \
    --docdir="${EPREFIX%/}"/usr/share/doc/${PN}-${PV} \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    --enable-freetype \
    --enable-fontconfig \
    --enable-openjpeg \
    --disable-compile-inits \
    --with-drivers=ALL \
    --with-fontpath="${FONTPATH}" \
    --with-ijs \
    --with-jbig2dec \
    --with-libpaper \
    --enable-contrib \
    $(use_enable 'cups') \
    $(use_enable 'dbus') \
    $(use_enable 'gtk') \
    $(use_with 'cups' pdftoraster) \
    $(use_with 'unicode' libidn) \
    $(use_with 'X' x) \
    || die "configure... error"

  cd "${BUILD_DIR}/ijs/" || die

  ./configure \
    --prefix="${EPREFIX%/}" \
    --libdir="${EPREFIX%/}/$(get_libdir)" \
    --includedir="${INCDIR}" \
    --host=$(tc-chost) \
    --build=$(tc-chost) \
    $(use_enable 'shared') \
    $(use_enable 'static-libs' static) \
    || die "configure... error"

  cd "${BUILD_DIR}/" || die

  make -j"$(nproc)" V='0' \
    DESTDIR=${ED} \
    prefix='' \
    libdir="/$(get_libdir)" \
    includedir="/usr/include" \
    $(usex 'shared' so) $(usex !static all) \
    || die "Failed make build"

  make V='0' \
    DESTDIR=${ED} \
    prefix='' \
    $(usex 'shared' install-so) install \
    || die "make install... error"

  cd "${BUILD_DIR}/ijs/" || die

  make V='0' \
    DESTDIR=${ED} \
    prefix='' \
    install \
    || die "make install... error"

  cd "${BUILD_DIR}/" || die

  echo "Build static-libs..."
  use 'static' &&
  make -j"$(nproc)" V='0' \
    DESTDIR=${ED} \
    prefix='' \
    BUILDDIRPREFIX="a" \
    LDFLAGS="${LDFLAGS}${LDFLAGS:+ }-Wl,--gc-sections -s -static --static" \
    CFLAGS="${CFLAGS/-O[0-3]/-Os}${CFLAGS:+ }-ffunction-sections -fdata-sections" \
    CXXFLAGS="${CXXFLAGS/-O[0-3]/-Os}" \
    libgs gs \
    || die "Failed make build"

  cp -v -l "${BUILD_DIR}"/abin/gs -t "${ED}"/bin/
  cp -v -l "${BUILD_DIR}"/abin/gs.a "${ED}"/$(get_libdir)/libgs.a

  # move gsc to gs, bug #343447
  # gsc collides with gambit, bug #253064
  use 'static' || { mv -v "${ED}"/bin/gsc "${ED}"/bin/gs || die;}
}

pre_package() {
  # Sometimes the upstream versioning deviates from the tarball(!)
  # bug #844115#c32
  local my_gs_version=$(find "${ED}"/usr/share/ghostscript/ -maxdepth 1 -mindepth 1 -type d || die)
  my_gs_version=${my_gs_version##*/}

  mkdir -p -m 0755 -- "${ED}"/usr/share/ghostscript/${my_gs_version}/Resource/CMap/
  # Install the CMaps from poppler-data properly, bug #409361
  ln -s /usr/share/poppler/cMaps/* "${ED}"/usr/share/ghostscript/${my_gs_version}/Resource/CMap/

  use 'static-libs' || find "${ED}" -name '*.la' -print -delete || die

  [ -x "${ED}/bin/gsc" ] && rm -v -- "${ED}"/bin/gsc

  use 'doc' || rm -v -r -- usr/share/man/ usr/share/doc/
}
