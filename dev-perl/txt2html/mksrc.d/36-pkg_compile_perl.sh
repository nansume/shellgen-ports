# -static -static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Convert a plain text file to HTML"
HOMEPAGE="https://github.com/resurrecting-open-source-projects/txt2html"
NL="$(printf '\n\t')"; NL=${NL%?}
ED=${INSTALL_DIR}
PERL_VER=${PERL_VER:-5.34.0}

local EXIT='exit'; local IFS=${IFS}

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

# Build
test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

PERL_VER=$(printf /$(get_libdir)/perl*/site_perl/*.*)
PERL_VER=${PERL_VER##*/}

printf %s\\n "PERL_VER='${PERL_VER}'"

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

if test -f 'Build.PL'; then
  . runverb perl -- "Build.PL" \
    --destdir ${ED} \
    --install_path lib="/$(get_libdir)/perl5/site_perl/${PERL_VER}" \
    --install_path arch="/$(get_libdir)/perl5/site_perl/${PERL_VER}/$(tc-chost)" \
    || die
  perl -- "Build"
  . runverb perl -- "Build" install
fi

printf %s\\n "PWD=${PWD}" "WORKDIR=${WORKDIR}"

test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
