# +static +static-libs -doc -xstub -diet +musl +stest +strip +x32

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${WORKDIR}/

mkdir -pm 0755 "${ED}"/bin/

mv -n ${PN} "${ED}"/bin/ &&
printf %s\\n "mv -n ${PN} ${ED}/bin/"
