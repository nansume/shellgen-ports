MYCONF="${MYCONF}
 --sysconfdir=/etc/${PN}
 --enable-sidebar
 --enable-compressed
 --enable-pop
 --enable-imap
 --enable-smtp
 --with-ssl
 $(use_enable 'doc')
 $(use_enable 'doc' 'full-doc')
 --without-bundled-regex
"
