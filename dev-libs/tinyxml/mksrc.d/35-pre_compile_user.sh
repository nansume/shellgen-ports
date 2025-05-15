FILESDIR=${DISTSOURCE}
BUILD_DIR=${WORKDIR}

local major_v=$(: ver_cut 1);   major_v="2"
local minor_v=$(: ver_cut 2-3); minor_v="62"

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

sed \
  -e "s:@MAJOR_V@:$major_v:" \
  -e "s:@MINOR_V@:$minor_v:" \
  "${FILESDIR}"/Makefile-3 > Makefile || die

use 'stl' && patch -p1 -E < "${FILESDIR}"/${PN}-${PV}-defineSTL.patch

sed -e "s:/lib:/$(get_libdir):g" -i tinyxml.pc || die  # bug 738948
if use 'stl'; then
  sed -e "s/Cflags: -I\${includedir}/Cflags: -I\${includedir} -DTIXML_USE_STL=YES/g" -i tinyxml.pc || die
fi

if ! use 'static-libs'; then
  sed -e "/^all:/s/\$(name).a //" -i Makefile || die
fi
