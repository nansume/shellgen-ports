dietlibc-0.35 - err build x32abi
-------------------------------------------------------------------------------
# BUG: nobuild x32abi
# BUG: gcc <opts> -I. -isystem include <opts> -fpie -c syscalls.s/close_range.S <opts> -o bin-x32/close_range.o
-------------------------------------------------------------------------------
gcc -D__dietlibc__ -I. -isystem include -mx32 -I. -isystem include -mx32 -fno-stack-protector -ffunction-sections -fdata-sections -Oz -g0 -march=x86-64 -no-pie -W -Wall -Wchar-subscripts -Wmissing-prototypes -Wmissing-declarations -Wno-switch -Wno-unused -Wredundant-decls -fno-strict-aliasing -Wa,--noexecstack -fpie -ffunction-sections -fdata-sections -c syscalls.s/close_range.S -Wa,--noexecstack -o bin-x32/close_range.o
syscalls.s/close_range.S: Assembler messages:
syscalls.s/close_range.S:3: Error: non-constant expression in ".if" statement
make[1]: *** [Makefile:204: bin-x32/close_range.o] Error 1
make[1]: Leaving directory '/build/dietlibc-0.35'
make: *** [Makefile:459: x32] Error 2
make build... error
-------------------------------------------------------------------------------
Failed make build