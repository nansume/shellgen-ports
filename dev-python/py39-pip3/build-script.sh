#!/bin/sh /usr/ports/profiles/libexec.d/prepkgs.sh
# Maintainer: Artjom Slepnjov <shellgen-at-uncensored-dot-citadel-dot-org>
# Date: 2026-02-16 11:00 UTC - last change
# Build with useflag: -static -static-libs -shared -lfs -nopie -patch -doc -xstub -diet (+musl) -stest -strip +noarch

# Compatible with python-3.12

# <orig-url-build-script>  usr/ports/dev-python/py39-installer/build-script.sh

EAPI=8

inherit autotools lua-single toolchain-funcs

DESCRIPTION="<pkgdesc>"
HOMEPAGE="<url>"
LICENSE="<license>"
PN="pip"
XPN="py39-pip3"
PV="24.3.1"
SRC_URI="https://files.pythonhosted.org/packages/source/p/pip/${PN}-${PV}.tar.gz"
IUSE="-doc"

pkgins() { pkginst \
  "app-crypt/libb2  # deps python (optional)" \
  "dev-lang/python3-12" \
  "dev-libs/libffi  # deps python" \
  "dev-python/py39-flitcore" \
  "dev-python/py39-installer" \
  "sys-libs/musl" \
  "sys-libs/zlib  # required" \
  || die "Failed install build pkg depend... error"
}

pre_build() {
  if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
    mkdir -m 0755 -- "/var/cache/python/"
    chown ${BUILD_USER}:${BUILD_USER} "/var/cache/python/"
  fi
}

build() {
  HOME=${ED}
  PYVER=$(python3 -c 'import sys; print("%s.%s" % sys.version_info[:2])')
  PYTHON_XLIBS="${ED}/lib/python${PYVER}/site-packages"

  # preinstall
  printf %s\\n 'python3 -m flit_core.wheel'
  python3 -m "flit_core".wheel || exit

  PYTHON_XLIBS=${INSTALL_DIR}

  printf %s\\n "PYTHONPATH=src python3 -m installer -d ${PYTHON_XLIBS} dist/*.whl"
  PYTHONPATH="src" \
  python3 -m "installer" -d ${PYTHON_XLIBS} --no-compile-bytecode dist/*.whl || exit
}

pre_package() {
  find "lib/python${PYVER}/" -name '*.exe' -print -delete || die
}
