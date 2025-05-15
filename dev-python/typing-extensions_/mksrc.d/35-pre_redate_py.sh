local IFS="$(printf '\n\t')"; IFS=${IFS%?}
local FAKETIME='1980-01-01 00:00:01'
local P

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "x${USER}" != 'xroot' || return 0

for P in $(dotglobstar); do
  test -e "${P}" || continue
  test -d "${P}" ||
  test "$(finfo -m ${P})" -ne '0' ||
  touch -ch -d "${FAKETIME}" "${P}" &&
  printf %s\\n "touch -ch -d [${FAKETIME}] ${P}"
done
