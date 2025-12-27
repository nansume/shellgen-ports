#########################################################
###  busybox-1.34.1 - cpio(bb) no support create dir  ###
#########################################################

# unpack archive - no support create dir
unxz -c ${PKG} | cpio -imd  # no work

cpio(bb) no support create dir
bug fix: remove opt '-d' createdir


###  create archive
##################################
fix: | cpio -H newc -o |