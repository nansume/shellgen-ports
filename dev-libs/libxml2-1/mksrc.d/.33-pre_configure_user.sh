BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

ln -s libxml2-python-api.xml python/libxml2-api.xml
