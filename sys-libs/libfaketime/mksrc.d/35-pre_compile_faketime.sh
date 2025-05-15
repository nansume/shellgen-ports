test "X${USER}" != 'Xroot' || return 0

case $(tc-chost) in
  *'musl'*)
    CFLAGS="${CFLAGS} -D_LARGEFILE64_SOURCE"
  ;;
esac
