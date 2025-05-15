#######################################
# no build: loop-aes-losetup #
#######################################
Can't exec "autopoint": No such file or directory at /usr/share/autoconf-2.69/Autom4te/FileUtils.pm line 345.
autoreconf-2.69: failed to run autopoint: No such file or directory
autoreconf-2.69: autopoint is needed because this package uses Gettext

install: gettext

# bug: not found - autopoint [autoreconf]
#  deps reuqred - gettext



============================================
ver: 2.30.1
# http://loop-aes.sourceforge.net/updates/util-linux-${PV}-$DATE.diff.bz2


# configure.ac:14: error: version mismatch. This is Automake 1.15.1
#
# error: version mismatch. This is Automake 1.15.1 but the definition - comes from Automake 1.14.1 - Stack Overflow
# stackoverflow.com/questions/48553511/error-version-mismatch-this-is-automake-1-15-1-but-the-definition-comes-fr?rq=1
# libtool version mismatch error - Stack Overflow
# https://stackoverflow.com/questions/3096989/libtool-version-mismatch-error/3205400
autoreconf --force --install