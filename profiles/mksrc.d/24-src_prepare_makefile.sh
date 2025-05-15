# Date: 2023-10-05 20:00 UTC - fix: near to compat-posix

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

#MAKEFLAGS=(${MAKEFLAGS[@]})

test -d "${WORKDIR}" || return 0
cd "${WORKDIR}/"

test -f 'Makefile' || return 0
# Makefile fix path
sed -i \
  -e "s|/usr/local/bin|/bin|" \
  -e "s|/usr/local/sbin|/sbin|" \
  -e "s|/usr/local/man|/usr/share/man|" \
  Makefile
