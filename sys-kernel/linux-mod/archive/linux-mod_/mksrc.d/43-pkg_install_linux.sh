# 2021-2023

local PN=${PKGNAME}; local ZCOMP='xz'; local KNAME=${PN#*-}

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }INSTALL_MOD_STRIP=1"  #V=0

if test -L '/bin/echo'; then
  set -o 'xtrace'
  rm '/bin/echo'
  { set +o 'xtrace';} >/dev/null 2>&1
fi

make ${MAKEFLAGS} INSTALL_MOD_PATH="${INSTALL_DIR}" modules_install
test -d '../../../pkg/' || mkdir -pm 0755 '../../../pkg/'

set -o 'xtrace'
cp -nl 'arch/x86/boot/bzImage' ../../../pkg/${PN}-${KNAME}_${PV}-${KDATE}_${ABI}.${ZCOMP}
cp -nl '.config' ${INSTALL_DIR}/lib/modules/${PV}/
{ set +o 'xtrace';} >/dev/null 2>&1

PV="${PV}-${KDATE}"

#touch -h -d "${FAKETIME} vmlinuz
#touch -h -d "${FAKETIME} .config
