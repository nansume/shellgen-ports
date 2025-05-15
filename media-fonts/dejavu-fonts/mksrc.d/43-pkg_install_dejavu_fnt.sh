local DPREFIX=${DPREFIX#/}; local PN=${PN%-*}; local GLOBIGNORE="${WORKDIR}/fontconfig/*-lgc-*.conf"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || ${EXIT}
cd ${INSTALL_DIR}/

set -o 'xtrace'

# usr/share/fonts/dejavu-fonts --> usr/share/fonts/dejavu ?
mkdir -pm '0755' ${DPREFIX}/share/fonts/${PN}/ etc/fonts/conf.avail/ etc/fonts/conf.d/

set -- ${WORKDIR}/build/*.ttf

test -e "${1}" && cp -nl ${@} "${DPREFIX}/share/fonts/${PN}/"

set -- ${WORKDIR}/fontconfig/*.conf
# skip: *-*-lgc-*.conf
test -e "${1}" && cp -nl ${@} "etc/fonts/conf.avail/"
# symlink [correct=no]: /usr/share/fontconfig/conf.avail/* /etc/fonts/conf.d/
# symlink [correct=yes]: /etc/fonts/conf.avail/* /etc/fonts/conf.d/
#ln -sf ../conf.avail/* etc/fonts/conf.d/

{ set +o 'xtrace';} >/dev/null 2>&1

printf %s\\n "Install... ok"
