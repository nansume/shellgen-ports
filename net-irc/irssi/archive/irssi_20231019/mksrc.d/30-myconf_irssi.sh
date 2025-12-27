MYCONF="${MYCONF}
 $(use_enable 'shared')
 $(use_enable 'static')
 $(use_with 'socks5' socks)
 $(use_with 'bot')
 $(use_with 'proxy')
 $(use_with 'mod' modules)
 --with-perl=$(usex 'perl' yes no)
 --with-otr=$(usex 'otr' yes no)
"
