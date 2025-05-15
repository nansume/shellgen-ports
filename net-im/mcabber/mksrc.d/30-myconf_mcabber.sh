MYCONF="${MYCONF}
 $(use_enable 'large' 'largefile')
 #$(use_enable static shared)
 $(use_enable 'static')
 $(use_enable 'mod' 'modules')
 $(use_enable 'gpgme')
 $(use_enable 'otr')
 $(use_enable 'debug')
"
