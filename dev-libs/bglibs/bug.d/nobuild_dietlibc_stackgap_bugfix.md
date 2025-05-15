==================================================================================
igger_pull.lo unix/trigger_set.lo
copying selected object files to avoid basename conflicts...
./ltload bg-installer libbg-cli.la libbg.la bg-installer-cli.o -lbg-cli -static
/bin/ld: /opt/diet/lib-x86_64/libc.a(stackgap.o): in function `stackgap':
(.text+0x1b6): undefined reference to `main'
collect2: error: ld returned 1 exit status
make: *** [Makefile:93: bg-installer] Error 1
Failed make build
==================================================================================

bugfix:
==================================================================================
add in ${LDFLAGS}: -g0
==================================================================================
printf '%s\n' "${CC} ${LDFLAGS} -g0" > conf-ld || die
==================================================================================