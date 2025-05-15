# 2022
# no-posix: ${X/a/b}

local PN=${PKGNAME}; local DPREFIX=${DPREFIX#/}; local F

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

#trap { shopt -uo xtrace;} &>/dev/null; trap - RETURN' RETURN

cd ${INSTALL_DIR}/ || return
set -o 'xtrace'

rm -- ${DPREFIX}/share/${PN}/decker.ttf
{ set +o 'xtrace';} >/dev/null 2>&1

for F in "/${DPREFIX}/share/directfb-"*"/decker.ttf"; do
  set -o 'xtrace'
  ln -s ${F/\/$DPREFIX\/share/..} ${DPREFIX}/share/${PN}/
done
