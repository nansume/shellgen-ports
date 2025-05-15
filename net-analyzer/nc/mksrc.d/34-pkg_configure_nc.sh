# 2021 nc-utils: slot=1

test "x${USER}" != 'xroot' && {
  cd ${WORKDIR}/

  sed -i \
   -e '/#define HAVE_BIND/s:#define:#undef:' \
   -e '/#define FD_SETSIZE 16/s:16:1024: #34250' \
   netcat.c
}
