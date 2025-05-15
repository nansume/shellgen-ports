# bug fix:
#  Fontconfig error: Cannot load config file `infinality/conf.d`
#
# Gentoo Forums :: View topic - infinality fonts failing after upgrade
#  https4://forums.gentoo.org/viewtopic-t-1079210-start-0.html

ln -vs etc/fonts/infinality/styles.conf.avail/${OSTYPE%-*}/ etc/fonts/infinality/conf.d