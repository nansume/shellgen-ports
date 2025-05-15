#!/bin/sh

BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
BINPROGS="ldapclient ldapclient_str md5password mysql2ldif tinyldapdelete"
SBINPROGS="acl addindex bindrequest dumpacls dumpidx idx2ldif"
SBINPROGS="${SBINPROGS} parse ${PN}_debug ${PN}_standalone"  # no needed: t1 t2

local IFS="$(printf '\n\t') "

test "X${USER}" != 'Xroot' || return 0

test -d "${BUILD_DIR}" || return
cd "${BUILD_DIR}/"

mkdir -pm 0755 -- "${ED}"/ "${ED}"/bin/ "${ED}"/sbin/ "${ED}"/usr/ "${ED}"/usr/libexec/

mv -v -n ldapdelete tinyldapdelete
mv -v -n ${BINPROGS} -t "${ED}"/bin/
mv -v -n ${SBINPROGS} -t "${ED}"/sbin/
mv -v -n ${PN} -t "${ED}"/usr/libexec/

printf %s\\n "Install: ${PN}"
