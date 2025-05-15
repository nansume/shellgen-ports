local DPREFIX=${DPREFIX#/}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || exit 0
cd ${WORKDIR}/

test -d "../../${DPREFIX}/share/unicode-data" || exit
test -d "../../${DPREFIX}/share/fc-lang" || exit
set -o 'xtrace'

mkdir -pm 0755 "resources/"
ln -sf ../../../${DPREFIX}/share/unicode-data/* "resources/"  # pkg: <unicode-data>
ln -sf ../../../${DPREFIX}/share/fc-lang "resources/"  # pkg: <fontconfig>

{ set +o 'xtrace';} >/dev/null 2>&1
#export FC-LANG=/usr/share/fc-lang
