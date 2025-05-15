MYCONF="${MYCONF}
 $(use_enable 'debug')
 --disable-device-mapper
 --enable-pc98=no
 $(use_with 'readline')
 --disable-threads
"
