test "${BUILD_CHROOT:=0}" -ne '0' || return 0
test "X${USER}" != 'Xroot' && return

XUSER="fake"

sed -e "s/\(^\|[^A-z]\)${BUILD_USER}\(^$\|[^A-z]\)/\1${XUSER}\2/g" -i /etc/passwd /etc/group

BUILD_USER=${XUSER}

printf %s\\n "adduser ${XUSER}"
