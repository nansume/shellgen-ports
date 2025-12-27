########################################
###  dropbear - include libtomcrypt  ###
########################################


##############################
# dropbear_2016.74 - x32 bug #
##############################

checking for gai_strerror... yes
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%eax' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%r9d' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%esi' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%r8d' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%esi' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%eax' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%r15d' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%esi' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%r8d' used with `q' suffix
./src/headers/tomcrypt_macros.h:356: Error: incorrect register `%edi' used with `q' suffix
make[1]: *** [<builtin>: src/hashes/sha2/sha512.o] Error 1
make: *** [Makefile:198: libtomcrypt/libtomcrypt.a] Error 2


##################################
new version fix: =dropbear_2018.76