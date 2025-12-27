MYCONF="${MYCONF}
 $(use_enable 'debug')
 $(use_enable 'irc-plus' ircplus)
 $(use_enable 'ipv6')
 $(use_with 'irc-plus' iconv)
 $(use_with 'ident')
 $(use_with 'tcpd' tcp-wrappers)
 $(use_with 'zlib')
 $(use_with 'gnutls')
 $(use_with 'openssl')
"
