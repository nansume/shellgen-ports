MYCONF="${MYCONF}
 #--enable-8bit=no
 #--enable-cases=no
 --with-audio=$(usex 'tinyalsa' tinyalsa alsa)
 --with-default-audio=$(usex 'tinyalsa' tinyalsa alsa)
 --with-cpu=${HOSTTYPE%[-_]*}-${HOSTTYPE#*[-_]}
 --enable-32bit=$(usex '24bit' yes no)
 --enable-buffer=$(usex 'buffer' yes no)
 $(use_enable 'debug')
 --enable-downsample=no
 --enable-equalizer=no
 --enable-feeder=no
 --enable-fifo=$(usex 'fifo' yes no)
 --enable-gapless=no
 --enable-icy=no
 --enable-id3v2=no
 --enable-ieeefloat=no
 --enable-ipv6=$(usex 'ipv6' yes no)
 $(use_enable 'large' 'largefile')
 --enable-messages=no
 --enable-modules=$(usex 'modules' yes no)
 --enable-layer1=no
 --enable-layer2=no
 $(use_enable 'network')
 --enable-ntom=no
 --enable-real=no
 --with-optimization=$(usex 'optimization' 3 2)
"
