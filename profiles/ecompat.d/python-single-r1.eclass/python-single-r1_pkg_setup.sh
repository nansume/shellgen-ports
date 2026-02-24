#!/bin/sh

# TODO: Dir /var/cache/python/ replace user read-write dir.

python_single_r1_pkg_setup() {
  [ -x "/bin/python" ] || return 0
  if { test "X${USER}" = 'Xroot' && test "${BUILD_CHROOT:=0}" -ne '0' ;} ;then
    mkdir -m 0755 -- "/var/cache/python/"
    chown ${BUILD_USER}:${BUILD_USER} "/var/cache/python/"
  fi

  [ -x "/bin/python" ] && . "${PDIR%/}/etools.d/"epython
}

# hush - not implementation <alias> - replace to: func name no posix
if typeis 'alias' && [ -z "${BB_ASH_VERSION-}" ]; then
  alias python-single-r1_pkg_setup='python_single_r1_pkg_setup'
fi
# name func no-posix
if ! typeis 'alias' || [ -n "${BB_ASH_VERSION-}" ]; then
  python-single-r1_pkg_setup() { python_single_r1_pkg_setup $@;}
fi