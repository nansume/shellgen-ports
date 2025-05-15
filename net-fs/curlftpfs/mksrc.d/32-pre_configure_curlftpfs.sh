test "X${USER}" != 'Xroot' || return 0

# temporary resolve
case $(tc-chost) in
  *'musl'*)
    CFLAGS="${CFLAGS} -D__off_t=off_t"
  ;;
esac
