#!/bin/sh
# +static +static-libs -shared -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Interpreter for the PostScript language and PDF"
HOMEPAGE="https://ghostscript.com/ https://git.ghostscript.com/?p=ghostpdl.git;a=summary"
LICENSE="AGPL-3 CPL-1.0"
IUSE="+static +static-libs -shared -fontconfig (+musl) +stest (-test) +strip"
IUSE="${IUSE} -cups -dbus -gtk -l10n_de +static-libs -unicode -X -doc -xstub"
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX%/}
BUILD_DIR=${WORKDIR}

local IFS="${NL} "

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# Remove internal CMaps (CMaps from poppler-data are used instead)
rm -r Resource/CMap/ || die

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

. runverb \
./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --datarootdir="${DPREFIX}/share" \
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
  $(use_enable 'cups') \
  $(use_enable 'dbus') \
  $(use_enable 'gtk') \
  $(use_with 'cups' pdftoraster) \
  $(use_with 'unicode' libidn) \
  $(use_with 'X' x) \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

: cd "ijs/" || die

: . runverb \
./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  || die "configure... error"

: cd "../" || die

make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  prefix='' \
  libdir="/$(get_libdir)" \
  includedir="/usr/include" \
  $(usex 'shared' so) all \
  || die "Failed make build"

: make -j"$(nproc)" V='0' \
  DESTDIR=${ED} \
  prefix='' \
  libdir="/$(get_libdir)" \
  includedir="/usr/include" \
  -C ijs \
  || die "Failed make build"


make V='0' \
  DESTDIR=${ED} \
  prefix='' \
  $(usex 'shared' install-so) install \
  || die "make install... error"

rm -- Makefile

# move gsc to gs, bug #343447
# gsc collides with gambit, bug #253064
mv -f "${ED}"/bin/gsc "${ED}"/bin/gs || die

cd "${S}/ijs" || die

make V='0' \
  DESTDIR=${ED} \
  prefix='' \
  install \
  || die "make install... error"

# Sometimes the upstream versioning deviates from the tarball(!)
# bug #844115#c32
local my_gs_version=$(find "${ED}"/usr/share/ghostscript/ -maxdepth 1 -mindepth 1 -type d || die)
my_gs_version=${my_gs_version##*/}

# Install the CMaps from poppler-data properly, bug #409361
ln -s /usr/share/poppler/cMaps/* "${ED}"/usr/share/ghostscript/${my_gs_version}/Resource/CMap/

if ! use 'static-libs'; then
  find "${ED}" -name '*.la' -delete || die
fi
