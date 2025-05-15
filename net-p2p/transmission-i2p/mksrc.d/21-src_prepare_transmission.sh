test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

#[[ ${BUILD_PHASE:-post_unpack} == post_unpack" ]] || return 0

test -d "${WORKDIR}" || exit
cd ${WORKDIR}/

test -d 'third-party/libbob' && return

mkdir -m 0755 "third-party/libbob/"
# ok - color: green
printf %s\\n " \e[1;32m+\e[m ebuild/${CATEGORY}/${PN}... \e[0;33m${SCNAME##*/}\e[m"
