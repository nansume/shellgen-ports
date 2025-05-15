################################################################################################
#                  bug: net-dns/dnsmasq-2.85 - in run time: required NET_RAW                   #
################################################################################################
/sbin/rc.d/[0-9][0-9]-dnsmasq start   # here only dns (without dhcp)
dnsmasq: process is missing required capability NET_RAW
================================================================================================
NET_RAW is required to do an ICMP "ping" check on newly allocated addresses.
you can disable it with, then no require NET_RAW
================================================================================================


################################################################################################
#                  lixingcong/dnsmasq-regex: dnsmasq with regex match module                   #
################################################################################################
https://github.com/lixingcong/dnsmasq-regex
# support regex - dnsmasq 2.80
https://raw.githubusercontent.com/lixingcong/dnsmasq-regex/master/patches/001-regex-server.patch
================================================================================================