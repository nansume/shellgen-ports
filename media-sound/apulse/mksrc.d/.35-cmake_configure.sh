#!/bin/bash
# Copyright (C) 2023 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html


[[ -d ${WORKDIR} ]] || return 0
cd "${WORKDIR}/"

((BUILD_CHROOT)) || return 0
(( UID || "USE_BUILD_ROOT" )) || return 0

[[ -f "CMakeLists.txt" ]] || return 0
type -P cmake >/dev/null || return 0

[[ ${WORKDIR} != *"/build" ]] && {
  WORKDIR+="/build"
  mkdir -p build
  cd build/
}

[[ ${CMAKECONF-} ]] && declare -p CMAKECONF
# for fontforge add: -Wno-dev
cmake ${CMAKECONF-} -DCMAKE_INSTALL_PREFIX=${SPREFIX} -DCMAKE_BUILD_TYPE=Release -Wno-dev ..