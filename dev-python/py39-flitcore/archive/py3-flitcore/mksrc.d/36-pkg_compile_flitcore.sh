local PYTHON_XLIBS

# Build
test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || exit 0
cd ${WORKDIR}/

# python bootstrap_install.py flit_core-3.8.0-py3-none-any.whl
test -r 'bootstrap_install.py' || exit 0

PYTHON_XLIBS="${INSTALL_DIR}/lib/python${PYTHON_VER:?}/site-packages"

# create [preinstall]: ${PKGNAME}-${PV}-py3-none-any.whl
python -m ${PKGNAME}'.wheel'

# install
. runverb \
python "bootstrap_install.py" --install-root ${SPREFIX:?} --installdir ${PYTHON_XLIBS} dist/*.whl ||

! true
