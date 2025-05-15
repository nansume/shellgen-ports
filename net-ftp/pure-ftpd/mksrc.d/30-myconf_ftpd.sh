MYCONF="${MYCONF}
 # bug: no build (static only)
 #--with-minimal
 $(use_enable 'large' 'largefile')
 --disable-pie
 --disable-ssp
 $(use_with 'inetd')
 --without-capabilities
 --without-shadow
 --without-usernames
 --without-humor
 --without-longoptions
 --without-ascii
 --without-globbing
 --without-nonalnum
 $(use_with 'unicode')
 --without-sendfile
 --without-privsep
 --without-pam
 --without-iplogging
 --without-tls
 --without-uploadscript
 --without-quotas
 --without-ftpwho
"
