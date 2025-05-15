local PN="fc-lang"
local DPREFIX=${DPREFIX#/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

set -o 'xtrace'

mkdir -pm '0755' ${DPREFIX}/share/${PN}/
cp -nl ${WORKDIR}/${PN}/*.orth "${DPREFIX}/share/${PN}/"

{ set +o 'xtrace';} >/dev/null 2>&1
printf %s\\n "Install... ok"
