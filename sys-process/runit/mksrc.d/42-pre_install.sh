#!/bin/sh
# +static -static-libs -shared -upx -patch -doc -man -xstub +diet -musl +stest +strip +x32

inherit toolchain-funcs flag-o-matic install-functions

DESCRIPTION="A UNIX init scheme with service supervision"
HOMEPAGE="https://smarden.org/runit/"
LICENSE="BSD"
IUSE="+static"
DOCS="../package/CHANGES ../package/README ../package/THANKS ../package/TODO"
HTML_DOCS="../doc/*.html"
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}

export PN PV ED BUILD_DIR DOCS HTML_DOCS

local IFS="$(printf '\n\t') "

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

cp -L -f "${FILESDIR}"/ctrlaltdel -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/1-${PV} -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/2-${PV} -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/3-${PV} -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/finish.getty -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/run.getty-${PV} -t "${FILESDIR}"/

into /
dobin $(cat ../package/commands)
dodir /sbin
mv -n "${ED}"/bin/runit-init "${ED}"/bin/runit "${ED}"/bin/utmpset -t "${ED}"/sbin/ || die "dosbin"
dosym ../etc/runit/2 /sbin/runsvdir-start

einstalldocs
doman ../man/*.1 ../man/*.8

dodir /etc/runit
exeinto /etc/runit
doexe "${FILESDIR}"/ctrlaltdel
newexe "${FILESDIR}"/1-${PV} 1
newexe "${FILESDIR}"/2-${PV} 2
newexe "${FILESDIR}"/3-${PV} 3

dodir /etc/sv
for tty in tty1 tty2 tty3 tty4 tty5 tty6; do
  exeinto /etc/sv/getty-${tty}/
  cp -vn "${FILESDIR}"/finish.getty "${ED}"/etc/sv/getty-${tty}/finish
  cp -vn "${FILESDIR}"/run.getty-${PV} "${ED}"/etc/sv/getty-${tty}/run
  for script in finish run; do
    sed -i -e "s:TTY:${tty}:g" "${ED}"/etc/sv/getty-${tty}/${script}
  done
done

printf %s\\n "Install: ${PN}... ok"
