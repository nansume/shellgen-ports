#########################################################
###   sshfs-3.2.0.tar.gz - No package 'fuse3' found   ###
#########################################################

[https://github.com/libfuse/sshfs/releases/download/sshfs-3.2.0/sshfs-3.2.0.tar.gz]
========================================================================================

# sshfs - last pkg ver: support <autotools>
#  reqired libfuse-3.1
sshfs-3.2.0.tar.gz
========================================================================================

# bug
configure: error: Package requirements (fuse3 >= 3.1 glib-2.0 gthread-2.0) were not met:
No package 'fuse3' found
========================================================================================

# fix: install
deps reqired: fuse-3.1
========================================================================================