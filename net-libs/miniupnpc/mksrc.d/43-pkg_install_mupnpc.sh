# 2021

local F

test "x${USER}" != 'xroot' || return 0

mkdir -pm '0755' ${INSTALL_DIR}/bin/ ${INSTALL_DIR}/$LIB_DIR/

cd ${INSTALL_DIR}/
for F in "${WORKDIR}/build/"*"-shared"; do
  F=${F%-shared}
  cp -vnul ${F}-shared bin/${F##*/}
done

for F in "${WORKDIR}/build/lib"*".so"; do
  cp -vnul ${F} ${LIB_DIR}/${F##*/}.17
done
