#!/bin/sh
# -static -static-libs -shared -lfs -upx -patch -doc -man -xstub -diet -musl -stest -strip +noarch

inherit install-functions

DESCRIPTION="Linux Malware Detect (LMD) is a malware scanner for Linux released under the GNU GPLv2 license"
HOMEPAGE="http://www.rfxn.com/projects/linux-malware-detect/"
LICENSE="GPL-2"
IUSE="+inotify"
EPREFIX=${EPREFIX:-$SPREFIX}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV EPREFIX BUILD_DIR ED

local IFS="$(printf '\n\t') "; local EPREFIX=${SPREFIX%/}

unset MAKEFLAGS

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

sed \
  -e "s#inspath='/usr/local/maldetect'#inspath=/usr/libexec/maldet#" \
  -e 's#tmp_inspath=/usr/local/lmd_update#tmp_inspath=/tmp/maldet_update#' \
  -e 's#$inspath/maldet#/sbin/maldet#g' \
  -e "s#lmdup() {#lmdup() {\necho 'Use portage to update this!'\nexit 1#" \
  -i 'files/maldet' || die

sed \
  -e 's#ignore_paths=$inspath/ignore_paths#ignore_paths=/etc/maldet/ignore_paths#' \
  -e 's#inspath=/usr/local/maldetect#inspath=/usr/libexec/maldet#' \
  -e 's#conf.maldet#maldet.conf#g' \
  -e 's#confpath="$inspath"#confpath=/etc/maldet/#' \
  -e 's#ignore_sigs="$inspath/ignore_sigs"#ignore_sigs=/etc/maldet/ignore_sigs#' \
  -e 's#ignore_inotify="$inspath/ignore_inotify"#ignore_inotify=/etc/maldet/ignore_inotify#' \
  -e 's#ignore_file_ext="$inspath/ignore_file_ext"#ignore_file_ext=/etc/maldet/ignore_file_ext#' \
  -e 's#tmpdir="$inspath/tmp"#tmpdir=$varlibpath/tmp#' \
  -e 's#hex_fifo_path="$varlibpath/internals/hexfifo"#hex_fifo_path=$varlibpath/hexfifo#' \
  -e 's#inotify_log="$inspath/logs/inotify_log"#inotify_log=$logdir/inotify_log#' \
  -e 's#logdir="$inspath/logs"#logdir=/var/log/maldet#' \
  -e 's#varlibpath="$inspath"#varlibpath=/var/maldet#' \
  -i 'files/internals/internals.conf' || die

sed \
  -e 's#BASERUN="/usr/local/maldetect/tmp"#BASERUN=/var/maldet/tmp#' \
  -i 'files/internals/tlog' || die

sed \
  -e 's#/usr/local/maldetect/#/var/maldet/#g' \
  -i 'files/internals/hexfifo.pl' || die

sed \
  -e 's#/usr/local/maldetect/#/var/maldet/#g' \
  -i 'files/internals/hexstring.pl' || die

sed \
  -e "s#inspath='/usr/local/maldetect'#exepath=/sbin#" \
  -e 's#intcnf="$inspath/internals/internals.conf"#intcnf=/usr/libexec/maldet/internals/internals.conf#' \
  -e 's#inspath#exepath#' \
  -e 's#\&& success || failure##g' \
  -i 'files/service/maldet.sh' || die

echo '/var/maldet' > files/ignore_paths

insinto /etc/maldet || die
newins files/conf.maldet maldet.conf || die
doins files/ignore_file_ext || die
doins files/ignore_inotify || die
doins files/ignore_paths || die
doins files/ignore_sigs || die
insinto /usr/libexec/maldet/internals || die
doins files/internals/* || die
exeinto /usr/libexec/maldet/internals || die
doexe files/internals/tlog

keepdir /var/log/maldet || die
dodir /var/maldet || die
dodir /var/maldet/clean || die
keepdir /var/maldet/quarantine || die
keepdir /var/maldet/sess || die
: dodir /var/maldet/sigs || die
keepdir /var/maldet/inotify || die
: insinto /var/maldet/sigs || die
: doins files/sigs || die
mv -n files/sigs -t "${ED}"/var/maldet/ || die
keepdir /var/maldet/tmp || die
insinto /var/maldet/clean || die
doins files/clean/* || die

dosbin files/maldet || die
doman files/maldet.1 || die
dodoc README || die
dodoc CHANGELOG || die
