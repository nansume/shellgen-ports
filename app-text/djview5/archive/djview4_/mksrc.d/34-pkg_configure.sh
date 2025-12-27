#!/bin/sh
# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Portable DjVu viewer using Qt"
HOMEPAGE="https://djvu.sourceforge.net/djview4.html"
LICENSE="GPL-2+"
IUSE="-debug"
NL="$(printf '\n\t')"; NL=${NL%?}
EPREFIX=${SPREFIX}
BUILD_DIR=${WORKDIR}

local IFS="${NL} "

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

# Force XEmbed instead of Xt-based mainloop (disable Xt autodep)
sed -e 's:\(ac_xt=\)yes:\1no:' -i configure* || die

#append-ldflags $(test-flags-CCLD -Wl,--undefined-version)

#mv configure.in configure.ac || die
#autoreconf --install

#./configure ${MYCONF} || return

QTDIR="${QTDIR}" \
./configure \
  --prefix="${EPREFIX}" \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --libdir="${EPREFIX%/}/$(get_libdir)" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --host=$(tc-chost) \
  --build=$(tc-chost) \
  --disable-nsdejavu \
  $(use_enable 'shared') \
  $(use_enable 'static-libs' static) \
  || die "configure... error"

: sed -i -e "s:\$(PREFIX):${ED}:" Makefile
: sed -i -e "s:\$(LIBDIR):${ED}\$(LIBDIR):" librhash/Makefile

#mkdir -pm 0755 "${ED}"/$(get_libdir)/
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so.1 &&
#ln -s lib${PN}.so.${PV} "${ED}"/$(get_libdir)/lib${PN}.so &&
#printf %s\\n "fix symlink: lib${PN}.so.1.4.4"

: printf '%s\n' HAVE_FLTK=$(usex 'fltk' yes no) >> config.mak

printf "Configure directory: ${PWD}/... ok\n"
