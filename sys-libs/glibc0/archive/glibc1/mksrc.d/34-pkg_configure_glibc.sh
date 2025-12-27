local IFS="$(printf '\n\t')"; IFS=${IFS%?}

test "X${USER}" != 'Xroot' || return 0

WORKDIR="${WORKDIR}/${PKGNAME}-build"

MAKEFLAGS=$(mapsetre 'CC=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(mapsetre 'CXX=*' '' ${MAKEFLAGS})
MAKEFLAGS=$(mapsetnorm ${MAKEFLAGS})

MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --sbindir=${SPREFIX%/}/sbin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --libexecdir=${DPREFIX}/libexec
 --datarootdir=${DPREFIX}/share
 --host=${CHOST}
 --build=${CHOST}
 $(use_enable 'rpath')
 $(use_enable 'nls')
 $(use_enable 'shared')
 $(use_enable 'static-libs' static)
 $(use_enable 'ssp' libssp)
 $(use_enable 'ssp' stack-protector)
 $(use_with 'selinux')
 --disable-werror
 $(use_enable 'profile')
 $(use_with 'gd')
 $(use_enable 'crypt')  # required: build cups
 $(use_enable 'multiarch' multi-arch)
 $(use_enable 'static-pie')
 $(use_enable 'systemtap')
 $(use_enable 'nscd')
 $(use_enable 'vanilla' timezone-tools)
"

mkdir -pm 0755 "${WORKDIR}/" "${INSTALL_DIR}/etc/"
cd ${WORKDIR}/
printf %s\\n "WORKDIR='${WORKDIR}'"

MYCONF=$(mapsetnorm ${MYCONF})
IFS=' '

printf %s\\n "libc_cv_slibdir=/${LIB_DIR} ../configure ${MYCONF}"

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'
libc_cv_slibdir="/${LIB_DIR}" ../configure ${MYCONF} || exit
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'

printf %s\\n "Configure directory: ${PWD}/... ok"

>>${INSTALL_DIR}/etc/ld.so.conf
