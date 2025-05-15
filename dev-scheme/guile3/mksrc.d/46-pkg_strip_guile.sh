test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

for F in $(globstar); do
  case ${F} in
    *'/'*'.go') continue
    ;;
    'bin/'* | ${LIB_DIR}/* | 'lib/'* | 'sbin/'* | 'opt/'* | 'usr/libexec/'* )
    ;;
    *) continue;;
  esac
  testelf ${F} && strip --verbose --strip-all ${F}
done
