#!/bin/sh

use 'musl' && USE="${USE} -glibc"
use 'static-libs' && USE="${USE} +static"  # otherwise here it impossible.

MYCONF="${MYCONF}
 --with-usrlibdir=${EPREFIX%/}/$(get_libdir)
 --enable-pkgconfig
 --with-default-dm-run-dir=/run
 --with-default-run-dir=/run/lvm
 --with-default-locking-dir=/run/lock/lvm
 --with-default-pid-dir=/run
 $(usex 'static' --enable-static_link)
 --with-symvers=$(usex 'glibc' gnu no)
"
