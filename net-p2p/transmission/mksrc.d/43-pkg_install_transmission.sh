{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

#[[ ${BUILD_PHASE:-post_install} == "post_install ]] || return 0
# if declare -F ${BUILD_PHASE} &> /dev/null; then

# error - color: red
#printf '%s\n " \e[;31m++\e[m ${BASH_SOURCE##*/} \e[1;33m${BUILD_PHASE}\e[m... \e[1;31merror\e[m
test -d "usr/share/${PN}/web" || return 0

set -o 'xtrace'

#mv -n usr/share/${PN}/web/index.html usr/share/${PN}/web/index_old.html

{ set +o 'xtrace';} >/dev/null 2>&1
# ok - color: green
printf %s\\n " \e[1;32m+\e[m ebuild/${CATEGORY}/${PN}... \e[0;33m${SCNAME##*/}\e[m"
#set +o nounset +o pipefail +o errexit
