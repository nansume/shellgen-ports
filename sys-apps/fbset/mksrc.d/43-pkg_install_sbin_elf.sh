# 2022-2024
# +static -static-libs -shared +nopie -lfs -upx +patch -doc -man -xstub +diet -musl +stest +strip +x32

DESCRIPTION="A utility to set the framebuffer videomode"
HOMEPAGE="http://users.telenet.be/geertu/Linux/fbdev/"
LICENSE="GPL-2"
IUSE="static"

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

mkdir -pm '0755' -- ${INSTALL_DIR}/bin/ ${INSTALL_DIR}/etc/

for P in *; do
  case ${P} in *'.o') continue;; esac
  testelf ${P} || continue
  mv -n ${P} -t "${INSTALL_DIR}"/bin/
done

mv -n modeline2fb -t "${INSTALL_DIR}"/bin/
mv -n etc/fb.modes.* -t "${INSTALL_DIR}"/etc/
