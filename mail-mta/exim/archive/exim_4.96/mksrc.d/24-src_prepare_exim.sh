test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

test -d "${WORKDIR}" || exit
cd ${WORKDIR}/

cp -nl 'src/EDITME' 'Local/Makefile'

sed -i \
  -e "s|^BIN_DIRECTORY=.*|BIN_DIRECTORY=/bin|" \
  -e "s|^CONFIGURE_FILE=.*|CONFIGURE_FILE=/etc/${PN}/${PN}.conf|" \
  -e "s|^EXIM_USER=$|EXIM_USER=ref:smtp|" \
  -e "s|^SPOOL_DIRECTORY=.*|SPOOL_DIRECTORY=/var/spool/mail|" \
  -e "s|.*DISABLE_TLS=.*|DISABLE_TLS=yes|" \
  -e "s|###.*USE_OPENSSL=.*|USE_OPENSSL=yes|" \
  -e "s|###.*USE_GNUTLS=.*|USE_GNUTLS=yes|" \
  -e "s|.*SUPPORT_MBX=.*|SUPPORT_MBX=yes|" \
  -e "s|^LOOKUP_DBM=.*|LOOKUP_CDB=yes|" \
  -e "s|^LOOKUP_LSEARCH=.*|LOOKUP_DSEARCH=yes|" \
  -e "s|^LOOKUP_DNSDB=.*|LOOKUP_PASSWD=yes|" \
  -e "s|^SUPPORT_DANE=.*||" \
  -e "s|###.*DISABLE_DKIM=.*|DISABLE_DKIM=yes|" \
  -e "s|.*DISABLE_PRDR=.*|DISABLE_PRDR=yes|" \
  -e "s|.*DISABLE_EVENT=.*|DISABLE_EVENT=yes|" \
  -e "s|###^FIXED_NEVER_USERS=.*|LOOKUP_CDB=yes|" \
  -e "s|###.*AUTH_PLAINTEXT=.*|AUTH_PLAINTEXT=yes|" \
  -e "s|^COMPRESS_COMMAND=.*|COMPRESS_COMMAND=gzip|" \
  -e "s|^ZCAT_COMMAND=.*|ZCAT_COMMAND=zcat|" \
  -e "s|^SYSTEM_ALIASES_FILE=.*|SYSTEM_ALIASES_FILE=/etc/mail/aliases|" \
  Local/Makefile
