# Date: 2023-10-15 18:00 UTC - fix: near to compat-posix, no-posix: local X=${X//a/b} X=${X/a/b}

local OPT=${SCNAME##*[/-]}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

OPT=${OPT#*#}
OPT=${OPT%.*}

OPT="--${OPT//[_+]/-}"

MYCONF="${MYCONF:+${MYCONF}${NL}}${OPT/@/=}"

printf %s\\n "add option: ${OPT}"
