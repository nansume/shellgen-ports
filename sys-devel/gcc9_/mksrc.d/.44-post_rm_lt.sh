# 2021-2022

local IFS="$(printf '\n\t')"; IFS=${IFS%?}

test -d "${INSTALL_DIR}" || return 0
cd ${INSTALL_DIR}/

{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

#set -o xtrace
for F in $(globstar "${LIB_DIR}/"); do
  case ${F} in *'/'*'.la') rm -- ${F};; esac
done
{ set +o 'xtrace';} >/dev/null 2>&1
