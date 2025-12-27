----------------------------------------------------------------------------------------------------
tinyldap-20091122 - x32abi bug: undefined reference to ftruncate64
----------------------------------------------------------------------------------------------------

==================================================================================
/opt/diet/bin/diet -Os diet -Os gcc -nostdinc -I. -I/opt/diet/include -I/usr/include -I/usr/include/libowfat -pipe -I. -Wall -W -Wextra -o tinyldap tinyldap.c ldif.a storage.a auth.a ldap.a asn1.a -Wl,--gc-sections -s -static --static -lowfat -llatin1
/opt/diet/bin/diet -Os diet -Os gcc -nostdinc -I. -I/opt/diet/include -I/usr/include -I/usr/include/libowfat -pipe -I. -Wall -W -Wextra -DSTANDALONE -o tinyldap_standalone tinyldap.c ldif.a storage.a auth.a ldap.a asn1.a -Wl,--gc-sections -s -static --static -lowfat -llatin1
/bin/ld: /tmp/ccFHaaPo.o: in function `marshal':
acl.c:(.text+0xc32): undefined reference to `ftruncate64'
collect2: error: ld returned 1 exit status
make: *** [Makefile:82: acl] Error 1
------------------------------------------------------------------------------------
Failed make build
==================================================================================
build:
  bin: ldapclient ldapclient_str md5password mysql2ldif tinyldapdelete
  sbin: addindex bindrequest dumpacls dumpidx idx2ldif parse tinyldap_standalone
  libexec: tinyldap
----------------------------------------------------------------------------------
nobuild:
  sbin: acl tinyldap_debug
==================================================================================