####  4e8c28ad6ecc89902f9cb2e76f2815bb1a8287ded278e15f7a36ca45f8bbcd02  perl-5.20.0.tar.gz
####  8d3721f24dc440c526ccf2213383a6b24e40e7e3a2765b0e39467918865a9d14  perl5.20_fix-microperl-makefile.patch

[http://www.cpan.org/src/5.0/perl-5.20.0.tar.gz]
[https://aur.archlinux.org/cgit/aur.git/plain/perl5.20_fix-microperl-makefile.patch]

================================================================================
# Microperl - The Perl Journal, Fall 2000 (utf-8,http,gzip,ipv4)
[http://www.foo.be/docs/tpj/issues/vol5_3/tpj0503-0003.html]
================================================================================
# Miniperl - Embedded Linux Systems - Halo Linux Services (utf-8,http,gzip,ipv4)
[http://www.halolinux.us/embedded-systems/miniperl.html]
================================================================================


####  24-src_prepare_mperl.sh
================================================================================
((UID)) || return 0

declare F SED=${SED:-minised}

cd ${WORKDIR}/
for F in 'uconfig'{,64}'.sh'; {
  #chmod -c 0644 ${F}
  # http://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=microperl
  ${SED} \
   -e "s|usr/local/||" ${F} \
   -e "s|/lib/|$LIBDIR/|" \
   -e "s|perl5/$PV|perl5|" \
   -e "s|unknown64|$CHOST|g" \
   -e "s|unknown|$CHOST|" > ${F}
}
================================================================================


####  26-makeflag_microperl.sh
================================================================================
# bug:  hv_func.h:177:23: warning: left shift count >= width of type [-Wshift-count-overflow]
#MAKEFLAGS+=" -f Makefile.micro regen_uconfig64
# x32 support ?
MAKEFLAGS+=" -f Makefile.micro regen_uconfig"
================================================================================

####  35-makeflag_rm_opt_mperl.sh
================================================================================
MAKEFLAGS=${MAKEFLAGS% regen_uconfig*}
================================================================================