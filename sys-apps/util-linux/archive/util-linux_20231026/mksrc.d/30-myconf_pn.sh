# no-posix: local VAR, ${VAR/a/b}

local PN=${XPN%-utils}

#prefix= usrlib_execdir=
MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}libdir=/${LIB_DIR}${NL}usrlib_exec_LTLIBRARIES=/${LIB_DIR}"

case ${PN} in
  'losetup'|'libuuid')
    MYCONF="${MYCONF:+${MYCONF}${NL}}--enable-${PN/-/_}"
    return
  ;;
esac

MYCONF="${MYCONF}
 --enable-libblkid
 --enable-libmount
 --enable-switch-root
"
