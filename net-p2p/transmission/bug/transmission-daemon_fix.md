######### bug: #########
# _LINUX_QUOTA_VERSION < 2
platform-quota.c: In function `getquota':
make[1]: *** [platform-quota.o] Error 1
#
# transmission - 2.80+ fix
[https://trac.transmissionbt.com/ticket/5413]
[https://trac.transmissionbt.com/raw-attachment/ticket/5413/000-platform-quota.c.patch]
#
######### fix: ######### ( old glibc-2.23 )
[http://slackware.cs.utah.edu/pub/slackware/slackware64-14.2/patches/packages/glibc-2.23-x86_64-4_slack14.2.txz]
headers - usr/include/sys/quota.h
================================================================================================================


#############################################################################
# bug transmission-daemon - fix: i2pd after 45min start transmission-daemon #
#############################################################################
bug: [08:45:11.350] Starting up I2P tunnel for session. (neti2p.c:206)



#############################################################################
bug: /bin/grep: configure.??: No such file or directory

fix: set +o noglob