# error: /bin/ld: attempted static link of dynamic object /libx32/libtextstyle.so
# fix: <sys-devel/gettext> required for <static> build
use 'static' && MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }LDFLAGS=-static"