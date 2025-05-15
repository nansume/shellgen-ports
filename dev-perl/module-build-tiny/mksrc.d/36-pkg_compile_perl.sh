NL="$(printf '\n\t')"; NL=${NL%?}
ED=${INSTALL_DIR}
#PERL_VER=${PERL_VER:-5.34.0}

local EXIT='exit'; local IFS=${IFS}; local HOME=${HOME}; local PYTHON_XLIBS; local MK; local X

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

# Build
test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

PERL_VER=$(printf /$(get_libdir)/perl*/site_perl/*.*)
PERL_VER=${PERL_VER##*/}

printf %s\\n "PERL_VER='${PERL_VER}'"

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

# https://metacpan.org/pod/Module::Build
if test -f 'Makefile.PL'; then
  : . runverb perl -- "Makefile.PL" DESTDIR=${ED} || die
  : rm -- "Makefile"
elif test -f 'Build.PL'; then
  . runverb perl -- "Build.PL" \
    --destdir ${ED} \
    --install_path lib="/$(get_libdir)/perl5/site_perl/${PERL_VER}" \
    --install_path arch="/$(get_libdir)/perl5/site_perl/${PERL_VER}/$(tc-chost)" \
    || die
  perl -- "Build"
  #perl Build test
  . runverb perl -- "Build" install
fi

printf %s\\n "PWD=${PWD}" "WORKDIR=${WORKDIR}"

test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
