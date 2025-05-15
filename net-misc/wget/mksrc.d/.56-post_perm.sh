# 2021-2022

local F

test "x${USER}" != 'xroot' && return

cd "${INSTALL_DIR}/" || return

for F in $(globstar); do
  case ${F} in "etc/${PN}rc" | 'lib/shell/wget.sh' );; *) continue;; esac
  test -e "${F}" || continue
  test -G "${F}" && continue
  set -o 'xtrace'
  chown root:network ${F}
  { set +o 'xtrace';} >/dev/null 2>&1
done
