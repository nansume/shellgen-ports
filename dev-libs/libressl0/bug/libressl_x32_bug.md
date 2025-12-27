###########################################################################################
#######  bug x32  libressl-3.4.2 -- crash                                           #######
###########################################################################################
# bug: elinks - aborted
#  build only - no work
build options: [asm]
===========================================================================================
bugfix:
 build options: [--disable-asm]
===========================================================================================



###########################################################################################
#######  bug-x32abi: libressl-3.8.0 -- no build                                     #######
###########################################################################################
  CC       bn/libcrypto_la-bn_err.lo
  CC       bn/libcrypto_la-bn_exp.lo
  CC       bn/libcrypto_la-bn_gcd.lo
../crypto/bn/arch/amd64/bn_arch.h: Assembler messages:
../crypto/bn/arch/amd64/bn_arch.h:61: Error: incorrect register `%r9d' used with `q' suffix
../crypto/bn/arch/amd64/bn_arch.h:83: Error: incorrect register `%edi' used with `q' suffix
make[2]: *** [Makefile:6403: bn/libcrypto_la-bn_div.lo] Error 1
make[2]: *** Waiting for unfinished jobs....
make[1]: *** [Makefile:2259: all] Error 2
make: *** [Makefile:460: all-recursive] Error 1
===========================================================================================
bugfix
 build options: [--disable-asm]
===========================================================================================