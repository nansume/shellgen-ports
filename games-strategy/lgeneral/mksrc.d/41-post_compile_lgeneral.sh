# 2022-2023

local EXIT='exit'; local PN=${PN%-*}; local DPREFIX=${DPREFIX#/}; local MKDIR=${MKDIR_S}

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0
#trap { shopt -uo xtrace;} &>/dev/null; trap - RETURN; cd ${WORKDIR}/' RETURN

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }inst_dir=/usr/share/${PN%%-*}"
# fix: error: install: can`t create - install/usr/share/lgeneral/{units,gfx}/: No such dir
#. ${MKDIR} -pm 0755 ${INSTALL_DIR}/${DPREFIX}/share/${PN}/{units,nations}/
#. ${MKDIR} -pm 0755 ${INSTALL_DIR}/${DPREFIX}/share/${PN}/gfx/{flags,units}/

test -d "${WORKDIR}/kukgen-data" && { cd ${WORKDIR}/kukgen-data/
  mkdir -pm '0755' ${INSTALL_DIR}/${DPREFIX}/share/${PN}/
  cp -nlr */ ${INSTALL_DIR}/${DPREFIX}/share/${PN}/
}
test -d "${WORKDIR}/lgeneral-data" && { cd ${WORKDIR}/lgeneral-data/
  ./configure ${MYCONF} || ${EXIT}
  ${IONICE_COMM} make ${MAKEFLAGS} || ${EXIT}
  make ${MAKEFLAGS} install || ${EXIT}
}
test -d "${WORKDIR}/pg-data" && {
  mkdir -vpm '0755' ${INSTALL_DIR}/${DPREFIX}/share/${PN}/
  # Generate scenario data
  SDL_VIDEODRIVER='dummy' \
  lgc-pg/lgc-pg --separate-bridges -s pg-data -d "${INSTALL_DIR}/${DPREFIX}/share/${PN}"
}
chmod o+rX -R ${INSTALL_DIR}/${DPREFIX}/share/${PN}/*
