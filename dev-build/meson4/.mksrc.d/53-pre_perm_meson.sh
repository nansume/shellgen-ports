local IFS="$(printf '\n\t')"; IFS=${IFS%?}
local P

test "x${USER}" != 'xroot' || return 0

cd ${INSTALL_DIR}/ || exit

chmod o+rx "bin/${PN}" && printf %s\\n "chmod o+rx bin/${PN}"

for P in $(globstar); do
  test -e "${P}" &&
  case ${P} in
    'lib/'* ${LIB_DIR}/* 'share/'*)
      chmod o+rX "${P}" && printf %s\\n "chmod o+rX ${P}"
    ;;
  esac
done
