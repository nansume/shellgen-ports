#!/bin/sh

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

HOME='/install'

# run_profile_task
# test.test_asynchat.echo_client 127.0.0.1:43121
#[[ -e Tools/scripts/run_tests.py ]] && rm -- Tools/scripts/run_tests.py
#[[ -e Tools/test2to3/test/runtests.py ]] && rm -- Tools/test2to3/test/runtests.py
test -e 'Lib/test/libregrtest/runtest.py' && rm -- 'Lib/test/libregrtest/runtest.py'
