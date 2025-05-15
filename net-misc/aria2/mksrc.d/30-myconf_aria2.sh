# required: unset CC CXX LDFLAGS(only -s -static --static)
export ARIA2_STATIC=$(usex 'static' yes no)

printf %s\\n "ARIA2_STATIC='${ARIA2_STATIC}'"