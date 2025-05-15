MYCONF="${MYCONF}
 --enable-debug=$(usex 'debug' yes no)
 --with-ssl=$(usex 'gnutls' gnutls no)
"
