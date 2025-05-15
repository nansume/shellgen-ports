----------------------------------------------------------------------------------------------------
tinyldap-20170319 - tinyldap.c:2391:34: error: '__NR_mremap' undeclared (first use in this function)
----------------------------------------------------------------------------------------------------

==================================================================================
/opt/diet/bin/diet -Os diet -Os gcc -nostdinc -I. -I/opt/diet/include -I/usr/include -I/usr/include/libowfat -pipe -I. -Wall -W -Wextra -o x x.c tls.a -Wl,--gc-sections -s -static --static -lowfat -llatin1
tinyldap.c:2391:34: error: '__NR_mmap' undeclared (first use in this function)
 2391 |  BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_##name, 0, 1), \
      |                                  ^~~~~
tinyldap.c:2481:5: note: in expansion of macro 'ALLOW_SYSCALL'
 2481 |     ALLOW_SYSCALL(mmap),
      |     ^~~~~~~~~~~~~
tinyldap.c:2481:5: warning: missing initializer for field 'k' of 'struct sock_filter' [-Wmissing-field-initializers]
In file included from tinyldap.c:2359:
/opt/diet/include/linux/filter.h:26:11: note: 'k' declared here
   26 |  uint32_t k;      /* Generic multiuse field */
      |           ^
tinyldap.c:2391:34: error: '__NR_mremap' undeclared (first use in this function)
 2391 |  BPF_JUMP(BPF_JMP+BPF_JEQ+BPF_K, __NR_##name, 0, 1), \
      |                                  ^~~~~
tinyldap.c:2486:5: note: in expansion of macro 'ALLOW_SYSCALL'
 2486 |     ALLOW_SYSCALL(mremap),
      |     ^~~~~~~~~~~~~
tinyldap.c:2486:5: warning: missing initializer for field 'k' of 'struct sock_filter' [-Wmissing-field-initializers]
In file included from tinyldap.c:2359:
/opt/diet/include/linux/filter.h:26:11: note: 'k' declared here
   26 |  uint32_t k;      /* Generic multiuse field */
      |           ^
tinyldap.c: In function 'fixup':
tinyldap.c:117:5: warning: this statement may fall through [-Wimplicit-fallthrough=]
  117 |     {
      |     ^
tinyldap.c:136:3: note: here
  136 |   case AND:
      |   ^~~~
make: *** [Makefile:77: tinyldap] Error 1
make: *** Waiting for unfinished jobs....
tinyldap.c: In function 'fixup':
tinyldap.c:117:5: warning: this statement may fall through [-Wimplicit-fallthrough=]
  117 |     {
      |     ^
tinyldap.c:136:3: note: here
  136 |   case AND:
      |   ^~~~
/bin/ld: /opt/diet/lib-x86_64/libc.a(vsnprintf.o): in function `vsnprintf':
(.text+0x8e): warning: warning: the printf functions add several kilobytes of bloat.
/bin/ld: /opt/diet/lib-x86_64/libc.a(vsnprintf.o): in function `vsnprintf':
(.text+0x8e): warning: warning: the printf functions add several kilobytes of bloat.
------------------------------------------------------------------------------------
Failed make build
==================================================================================
build:
  ldapclient ldapclient_str ldapdelete md5password mysql2ldif
  acl addindex bindrequest dumpacls dumpidx idx2ldif parse
  tinyldap_debug tinyldap_standalone
----------------------------------------------------------------------------------
nobuild:
  tinyldap
==================================================================================
