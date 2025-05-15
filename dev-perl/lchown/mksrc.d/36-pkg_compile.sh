# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Use the lchown(2) system call from Perl"
HOMEPAGE="https://metacpan.org/release/Lchown"
PERL_VER=${PERL_VER:-5.34.0}
ED=${INSTALL_DIR}
BUILD_DIR=${WORKDIR}

test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

cd "${BUILD_DIR}/" || return

PERL_VER=$(printf /$(get_libdir)/perl*/site_perl/*.*)
PERL_VER=${PERL_VER##*/}

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

if test -f 'Build.PL'; then
  . runverb perl -- "Build.PL" \
    --destdir ${ED} \
    --install_path lib="/$(get_libdir)/perl5/site_perl/${PERL_VER}" \
    --install_path arch="/$(get_libdir)/perl5/site_perl/${PERL_VER}/$(tc-chost)" \
    || die
  perl -- "Build" --config optimize="${CFLAGS}"
  . runverb perl -- "Build" install

  test -f 'Makefile.PL' && rm -f -- "Makefile.PL"
fi

printf %s\\n "PWD='${PWD}'" "BUILD_DIR='${BUILD_DIR}'" "PERL_VER='${PERL_VER}'"

test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
