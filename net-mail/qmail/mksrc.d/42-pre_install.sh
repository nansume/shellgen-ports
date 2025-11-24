#!/bin/sh
# +static -static-libs -shared +nopie -lfs -upx +patch -doc -xstub +diet -musl +stest +strip +x32

# freebsd-ports-release-13.5.0/mail/qmail/Makefil
# https://www.mirrorservice.org/sites/www.linuxfromscratch.org/museum/blfs-museum/1.0/BLFS-1.0/server/qmail.html
# http://qmail.org/rpms/patches/
# https://raw.githubusercontent.com/bruceg/qmail-patches/master/qmail-1.03%2Bpatches.spec

DESCRIPTION="Qmail Mail Transfer Agent"
HOMEPAGE="http://qmail.org"
LICENSE="D. J. Bernstein, qmail@pobox.com"
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
PROGS=
#PROGS="auto-int auto-int8 auto-str binm1 binm1+df binm2 binm2+df binm3 binm3+df"
PROGS="${PROGS} bouncesaying chkshsgr chkspawn condredirect config config-fast datemail"
PROGS="${PROGS} dnscname dnsfq dnsip dnsmxip dnsptr elq except forward home home+df"
PROGS="${PROGS} hostname idedit install install-big instcheck ipmeprint maildir2mbox"
PROGS="${PROGS} maildirmake maildirwatch mailsubj make-owners pinq predate preline"
PROGS="${PROGS} proc proc+df qail qbiff qmail-clean qmail-getpw qmail-inject qmail-local"
PROGS="${PROGS} qmail-lspawn qmail-newmrh qmail-newu qmail-pop3d qmail-popup qmail-pw2u"
PROGS="${PROGS} qmail-qmqpc qmail-qmqpd qmail-qmtpd qmail-qread qmail-qstat qmail-queue"
PROGS="${PROGS} qmail-remote qmail-rspawn qmail-send qmail-showctl qmail-smtpd qmail-start"
PROGS="${PROGS} qmail-tcpok qmail-tcpto qmail-upq qreceipt qsmhook sendmail splogger"
PROGS="${PROGS} tcp-env"
NROFF="true"

test "X${USER}" != 'Xroot' || return 0

local IFS="$(printf '\n\t') "

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

#make DESTDIR=${ED} -B install || die "make install... error"
#make DESTDIR=${ED} setup || die "make install... error"

mkdir -pm 0755 -- "${ED}"/bin/qmail/
mv -n ${PROGS} -t "${ED}"/bin/qmail/ &&
printf %s\\n "Install: ${PN}"
