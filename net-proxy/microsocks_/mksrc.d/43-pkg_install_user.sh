# +static +static-libs -doc -xstub -diet +musl +stest +strip +x32

# Multithreaded, small, efficient SOCKS5 server (standalone-server)
# http://deb.debian.org/debian/pool/main/m/microsocks/
# http://gpo.zugaina.org/net-proxy/microsocks

ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${WORKDIR}/

mkdir -pm 0755 "${ED}"/bin/

mv -n ${PN} "${ED}"/bin/ &&
printf %s\\n "mv -n ${PN} ${ED}/bin/"
