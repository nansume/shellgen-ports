#!/bin/sh
# Copyright (C) 2021-2025 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# Date: 2023-10-09 18:00 UTC - fix: near to compat-posix, no-posix: local VAR
# Date: 2024-10-04 11:00 UTC - last change

PYTHON=${PYTHON:-python}

export BUILD_DIR=${BUILD_DIR:-$WORKDIR}
export ED=${ED:-$INSTALL_DIR}

NL="$(printf '\n\t')"; NL=${NL%?}

local EXIT='exit'; local IFS=${IFS}; local HOME=${HOME}; local PYTHON_XLIBS; local MK; local X

test -d "${BUILD_DIR}" || return 0
cd "${BUILD_DIR}/"

# Build
test "0${BUILD_CHROOT}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "0${USE_BUILD_ROOT}" -ne '0' ;} || return 0

test -x '/opt/xbin/bash' && ln -sf 'bash' /opt/xbin/sh && printf %s\\n 'ln -sf bash -> /opt/xbin/sh'

test -f 'Makefile.PL' && {
  . runverb perl -- "Makefile.PL" || exit
}

if { use !static && use 'shared' && use 'static-libgcc' ;}; then
  [ -f "Makefile" ] && \
  sed \
    -e "s/-shared-libgcc/-static-libgcc/" \
    -e "s/-shared-libstdc++/-static-libstdc++/" \
    -i Makefile */Makefile
  printf "replace: s/-shared-libgcc/-static-libgcc/... ok"
fi

for MK in *; do
  test -x "/bin/meson" && break
  test -n "${MAKE}" || break
  case ${MK} in [Mm]akefile.* | [Mm]akefile | GNUmakefile | ${XMKFILE});; *) continue;; esac
  test -e "${MK}" || continue
  { test -r "setup.py" && test ! -x "configure" ;} && break  # Makefile call <./setup.py build>
  # .am .in - skip, no-Unix drop: .win .msc .bcb
  case ${MK} in *'.am'|*'.in'|*'.win'*|*'.msc'*|*'.bcb'*) continue;; esac
  MK=${MK##*/}
  MAKEFILE=${MK}
  case ' '${MAKEFLAGS}' ' in *' -f '*);; *) MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }-f ${MK}";; esac
  #if [[ -f Makefile || -f GNUmakefile || -f makefile || -f ${XMKFILE} ]]; then
  if test -n "${COPTS}"; then
    runverb ${IONICE_COMM} make ${MAKEFLAGS} "${COPTS}" || exit
  elif use 'static' || use 'diet'; then
    MAKEFLAGS=${MAKEFLAGS/-j [0-9][[:space:]]}
    MAKEFLAGS=${MAKEFLAGS/-j[0-9][[:space:]]}
    # testing
    IFS=${NL}
    ${MAKE} -j"$(nproc)" V='0' \
      CC="${CC}" \
      CXX="${CXX}" \
      ${MAKEFLAGS/--jobs=[0-9][[:space:]]} \
      || printf %s\\n "Failed make build"  # fix for: Failed tests
  else
    #runverb ${IONICE_COMM} make ${MAKEFLAGS} || exit
    runverb ${IONICE_COMM} ${MAKE} ${MAKEFLAGS} || die "Failed make build"
  fi
  printf %s\\n "MAKE='${MAKE}'" "PWD='${PWD}'" "WORKDIR='${WORKDIR}'" "BUILD_DIR='${BUILD_DIR}'"
  return
done

printf %s\\n "PWD='${PWD}'" "WORKDIR='${WORKDIR}'" "BUILD_DIR='${BUILD_DIR}'"

if test -x 'b2'; then
  . runverb ./b2 ${MYCONF} || exit
# TODO: add muon instead meson
elif [ "_${PYTHON:-true}" = '_true' ] || [ "_${PYTHON:-:}" = '_:' ]; then
  :
elif ! { test -x '/bin/python' || test -x '/bin/python3' || test -x '/bin/python2' ;}; then
  :
elif test -x "/bin/pip3" && { test -r 'setup.py' || test -r 'pyproject.toml' ;}; then
  HOME=${INSTALL_DIR}
  # 3rd party packages - installed here = <site-packages> dir
  if test -x "/bin/cc"; then
    PYTHON_XLIBS="${INSTALL_DIR}/$(get_libdir)/python${PYTHON_VER}/site-packages"
  else
    PYTHON_XLIBS="${INSTALL_DIR}/lib/python${PYTHON_VER}/site-packages"
  fi
  printf %s\\n "PYTHONPATH='${PYTHONPATH}'" "PYTHON='${PYTHON}'" "PYTHONPYCACHEPREFIX='${PYTHONPYCACHEPREFIX}'"
  printf %s\\n "PYTHON_VER='${PYTHON_VER}'" "PYTHON_PREFIX='${PYTHON_PREFIX}'"
  printf %s\\n "PYTHON_EXEC_PREFIX='${PYTHON_EXEC_PREFIX}'" "HOME='${HOME}'"
  printf %s\\n "PYTHONHOME='${PYTHONHOME}'" "PYTHON_XLIBS='${PYTHON_XLIBS}'"
  #. runverb python -m pip install ${PKGNAME} || return
  #PYTHONPATH=src pip3 ${PKGNAME} -w dist --no-build-isolation --no-deps ${PWD}
  #--prefix ${INSTALL_DIR} \
  #--platform linux_x86_64 \
  #--config-settings bdist_ext \
  #--no-use-pep517 \
  #--src src/ \
  . runverb \
  python3 -m "pip" install \
    --root "${SPREFIX:?}" \
    --target ${PYTHON_XLIBS} \
    --no-index \
    --find-links "file:///${DISTSOURCE#/}/" \
    --no-build-isolation \
    --no-deps ${PWD} \
    ${PKGNAME}==${PV} \
    || exit
  if test -x "/bin/cc"; then
    mkdir -pm 0755 -- "${INSTALL_DIR}"/lib/python${PYTHON_VER}/site-packages/
    for X in "${INSTALL_DIR}"/${LIB_DIR}/python${PYTHON_VER}/site-packages/*; do
      test -n "${X##*\*}" || continue
      X="${X#$INSTALL_DIR}"
      P="${X#/$LIB_DIR/}"
      P="${P%/site-packages/*}"
      printf %s\\n "ln -s ${X} lib/${P}/site-packages/"
      ln -s ${X} "${INSTALL_DIR}"/lib/${P}/site-packages/
    done
  fi
elif test -x "/bin/meson" && test -r "${WORKDIR}/meson.build"; then
  cd "${WORKDIR}/"
  ninja -C build
elif test -r 'setup.py'; then
  HOME=${INSTALL_DIR}
  # 3rd party packages - installed here = <site-packages> dir
  if test -x "/bin/cc"; then
    PYTHON_XLIBS="${INSTALL_DIR}/$(get_libdir)/python${PYTHON_VER}/site-packages"
  else
    PYTHON_XLIBS="${INSTALL_DIR}/lib/python${PYTHON_VER}/site-packages"
  fi
  # python setup.py install --root=${INSTALL_DIR}
  printf %s\\n "PYTHONPATH='${PYTHONPATH}'" "PYTHON='${PYTHON}'" "PYTHONPYCACHEPREFIX='${PYTHONPYCACHEPREFIX}'"
  printf %s\\n "PYTHON_VER='${PYTHON_VER}'" "PYTHON_PREFIX='${PYTHON_PREFIX}'"
  printf %s\\n "PYTHON_EXEC_PREFIX='${PYTHON_EXEC_PREFIX}'" "HOME='${HOME}'"
  printf %s\\n "PYTHONHOME='${PYTHONHOME}'" "PYTHON_XLIBS='${PYTHON_XLIBS}'"
  # --root <rootdir> | --prefix <subdir> || == <rootdir>/<subdir>
  # build + install
  . runverb \
  python "setup.py" install --root ${SPREFIX:?} --prefix ${INSTALL_DIR} --install-lib ${PYTHON_XLIBS} || exit
  # only build, without install
  # ./setup.py build
  if test -x "/bin/cc"; then
    mkdir -pm 0755 -- "${INSTALL_DIR}"/lib/python${PYTHON_VER}/site-packages/
    for X in "${INSTALL_DIR}"/${LIB_DIR}/python${PYTHON_VER}/site-packages/*; do
      test -n "${X##*\*}" || continue
      X="${X#$INSTALL_DIR}"
      P="${X#/$LIB_DIR/}"
      P="${P%/site-packages/*}"
      printf %s\\n "ln -s ${X} lib/${P}/site-packages/"
      ln -s ${X} "${INSTALL_DIR}"/lib/${P}/site-packages/
    done
  fi
elif test -r 'configure.py'; then  # required: build ninja
  printf %s\\n 'configure.py --bootstrap --verbose'
  python "configure.py" --bootstrap --verbose || exit
elif { for X in * */*; do case ${X} in noxfile.py|*.py|src/*.py)break;; *)false;; esac; done; }; then
  # new behavior install for python3 [3.6]
  PYTHON_XLIBS="${INSTALL_DIR}/lib/python${PYTHON_VER}/site-packages"  # ?python3.6
  # preinstall
  printf %s\\n 'python3 -m flit_core.wheel'
  python3 -m "flit_core".wheel || exit
  # install
  test -x "/bin/python3.8" && PYTHON_XLIBS=${INSTALL_DIR}  # testing 2024.10.05 - ?python3.8
  printf %s\\n "PYTHONPATH=src python3 -m installer -d ${PYTHON_XLIBS} dist/*.whl"
  PYTHONPATH="src" python3 -m "installer" -d ${PYTHON_XLIBS} dist/*.whl || exit
else
  printf %s\\n "Source to compile... Skip"
fi
test -x '/opt/xbin/hush' && ln -sf 'hush' /opt/xbin/sh && printf %s\\n 'ln -sf hush -> /opt/xbin/sh'
