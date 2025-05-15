test "X${USER}" != 'Xroot' || return 0

case $(tc-chost) in
  *'musl'*)
    CMAKEFLAGS="${CMAKEFLAGS} -DPT_LASTLOGX_FILE=\"/dev/null/lastlogx\""
    CMAKEFLAGS="${CMAKEFLAGS} -DPT_WTMPX_FILE=\"/dev/null/wtmpx\""
  ;;
esac
