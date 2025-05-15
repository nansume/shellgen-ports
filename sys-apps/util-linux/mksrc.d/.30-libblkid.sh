case ${XPN} in
  'libmount')
  ;;
  *) return;;
esac

MYCONF="${MYCONF:+${MYCONF}${NL}}--enable-libblkid"
