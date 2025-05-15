# +static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# See https://bugs.gentoo.org/835813 before bumping to 4.x!
inherit flag-o-matic multilib-minimal usr-ldscript

DESCRIPTION="Standard informational utilities and process-handling tools"
HOMEPAGE="https://sourceforge.net/projects/procps-ng/ https://gitlab.com/procps-ng/procps"
LICENSE="GPL-2"
IUSE="-elogind +kill -modern-top +ncurses -nls -selinux -static-libs -systemd -test -unicode"
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

export WORKDIR BUILD_DIR

MYCONF="${MYCONF}
 --disable-kill
 --disable-pidof
 --disable-modern-top
"

eapply "${FILESDIR}"/${PN}-3.3.11-sysctl-manpage.patch  #565304
eapply "${FILESDIR}"/${PN}-3.3.12-proc-tests.patch      #583036

# Please drop this after 3.3.17 and instead use --disable-w on musl.
use 'musl' && eapply "${FILESDIR}"/${PN}-3.3.17-musl-fix.patch  #794997

# http://www.freelists.org/post/procps/PATCH-enable-transparent-large-file-support
append-lfs-flags  #471102
